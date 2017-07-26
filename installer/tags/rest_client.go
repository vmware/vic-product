// Copyright 2016-2017 VMware, Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package tags

import (
	"bytes"
	"crypto/tls"
	"encoding/json"
	"fmt"
	"io"
	"io/ioutil"
	"net/http"
	"net/url"
	"strings"

	log "github.com/Sirupsen/logrus"

	"github.com/vmware/vic/pkg/errors"
)

const (
	RestPrefix = "/rest"
)

type RestClient struct {
	host     string
	scheme   string
	endpoint *url.URL
	insecure bool
	HTTP     *http.Client
	cookies  []*http.Cookie
	sessId   *string
}

// NewClient creates and returns a new RestClient based on specs given.
func NewClient(u *url.URL, insecure bool) *RestClient {
	log.Debugf("Create rest client")
	u.Path = RestPrefix
	c := &RestClient{
		endpoint: u,
		insecure: insecure,
		host:     u.Host,
		scheme:   u.Scheme,
		HTTP: &http.Client{
			Transport: &http.Transport{
				TLSClientConfig: &tls.Config{InsecureSkipVerify: insecure},
			},
		},
	}
	return c
}

func (c *RestClient) encodeData(data interface{}) (*bytes.Buffer, error) {
	params := bytes.NewBuffer(nil)
	if data != nil {
		if err := json.NewEncoder(params).Encode(data); err != nil {
			log.Debugf("Encoding data failed for: %s", errors.ErrorStack(err))
			return nil, errors.Trace(err)
		}
	}
	return params, nil
}

func (c *RestClient) call(method, path string, data interface{}, headers map[string][]string) (io.ReadCloser, http.Header, int, error) {
	params, err := c.encodeData(data)
	if err != nil {
		return nil, nil, http.StatusBadRequest, errors.Trace(err)
	}

	if data != nil {
		if headers == nil {
			headers = make(map[string][]string)
		}
		headers["Content-Type"] = []string{"application/json"}
	}

	body, hdr, statusCode, err := c.clientRequest(method, path, params, headers)
	if statusCode == http.StatusUnauthorized && strings.Contains(err.Error(), "This method requires authentication") {
		c.Login()
		log.Debugf("Rerun request after login")
		return c.clientRequest(method, path, params, headers)
	}

	return body, hdr, statusCode, errors.Trace(err)
}

func (c *RestClient) clientRequest(method, path string, in io.Reader, headers map[string][]string) (io.ReadCloser, http.Header, int, error) {
	expectedPayload := (method == http.MethodPost || method == http.MethodPut)
	if expectedPayload && in == nil {
		in = bytes.NewReader([]byte{})
	}

	req, err := http.NewRequest(method, fmt.Sprintf("%s%s", RestPrefix, path), in)
	if err != nil {
		return nil, nil, http.StatusBadRequest, errors.Trace(err)
	}

	req.URL.Host = c.host
	req.URL.Scheme = c.scheme

	if c.sessId != nil {
		req.Header.Set("vmware-api-session-id", *c.sessId)
	}

	if headers != nil {
		for k, v := range headers {
			req.Header[k] = v
		}
	}

	if expectedPayload && req.Header.Get("Content-Type") == "" {
		req.Header.Set("Content-Type", "application/json")
	}
	req.Header.Set("Accept", "application/json")

	resp, err := c.HTTP.Do(req)
	return c.handleResponse(resp, err)
}

func (c *RestClient) handleResponse(resp *http.Response, err error) (io.ReadCloser, http.Header, int, error) {
	statusCode := http.StatusBadRequest
	if resp != nil {
		statusCode = resp.StatusCode
	}
	if err != nil {
		if strings.Contains(err.Error(), "connection refused") {
			return nil, nil, statusCode, errors.Errorf("Cannot connect to endpoint %s. Is vCloud Suite API running on this server?", c.host)
		}
		return nil, nil, statusCode, errors.Errorf("An error occurred trying to connect: %v", errors.ErrorStack(err))
	}

	if statusCode < http.StatusOK || statusCode >= http.StatusBadRequest {
		body, err := ioutil.ReadAll(resp.Body)
		if err != nil {
			return nil, nil, statusCode, errors.Trace(err)
		}
		if len(body) == 0 {
			return nil, nil, statusCode, errors.Errorf("Error: request returned %s", http.StatusText(statusCode))
		}
		log.Debugf("Error response from vCloud Suite API: %s", bytes.TrimSpace(body))
		return nil, nil, statusCode, errors.Errorf("Error response from vCloud Suite API: %s", bytes.TrimSpace(body))
	}

	return resp.Body, resp.Header, statusCode, nil
}

// Login starts a session with the VCloud Suite API and saves the session id in the client.
// If session fails to connect, an error is thrown.
func (c *RestClient) Login() error {
	log.Debugf("Login to %s through rest API.", c.host)
	targetUrl := c.endpoint.String() + "/com/vmware/cis/session"

	request, err := http.NewRequest(http.MethodPost, targetUrl, nil)
	request.Header.Set("vmware-use-header-authn", "request")
	password, _ := c.endpoint.User.Password()
	request.SetBasicAuth(c.endpoint.User.Username(), password)
	if err != nil {
		return errors.Trace(err)
	}

	resp, err := c.HTTP.Do(request)

	if err != nil {
		return errors.Trace(err)
	}
	if resp == nil {
		return errors.New("Response is nil in Login.")
	}
	if resp.StatusCode != http.StatusOK {
		body, _ := ioutil.ReadAll(resp.Body)
		return errors.Errorf("Login failed for %s", bytes.TrimSpace(body))
	}

	type RespValue struct {
		Value string
	}

	var sessionId RespValue
	if err := json.NewDecoder(resp.Body).Decode(&sessionId); err != nil {
		log.Debugf("Decode response body failed for: %s", errors.ErrorStack(err))
		return errors.Trace(err)
	}

	c.sessId = &sessionId.Value

	log.Debugf("Login succeeded")
	return nil
}
