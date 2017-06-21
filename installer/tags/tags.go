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
	"encoding/json"
	"fmt"
	"io"
	"regexp"
	"strings"
	"net/http"

	log "github.com/sirupsen/logrus"

	"github.com/vmware/vic/pkg/errors"
)

const (
	TagURL = "/com/vmware/cis/tagging/tag"
)

type TagCreateSpec struct {
	CreateSpec TagCreate `json:"create_spec"`
}

type TagCreate struct {
	CategoryId  string `json:"category_id"`
	Description string `json:"description"`
	Name        string `json:"name"`
}

type Tag struct {
	Id          string   `json:"id"`
	Description string   `json:"description"`
	Name        string   `json:"name"`
	CategoryId  string   `json:"category_id"`
	UsedBy      []string `json:"used_by"`
}

// CreateTagIfNotExist takes in specs needed and query for the tag first.
// If the given tag has been created, it returns the tag id and no error.
// Otherwise it creates the tag and returns the tag id and any error encountered.
func (c *RestClient) CreateTagIfNotExist(name string, description string, categoryId string) (*string, error) {
	tagCreate := TagCreate{categoryId, description, name}
	spec := TagCreateSpec{tagCreate}
	id, err := c.CreateTag(&spec)
	if err != nil {
		log.Debugf("Created tag %s failed for %s", errors.ErrorStack(err))
		// if already exists, query back
		if strings.Contains(err.Error(), "already_exists") {
			tagObjs, err := c.GetTagByNameForCategory(name, categoryId)
			if err != nil {
				log.Errorf("Failed to query tag %s for category %s, for ", name, categoryId, errors.ErrorStack(err))
				return nil, errors.Trace(err)
			}
			if tagObjs != nil {
				return &tagObjs[0].Id, nil
			} else {
				// should not happen
				log.Debugf("Failed to create tag for it's existed, but could not query back. Please check system")
				return nil, errors.Errorf("Failed to create tag for it's existed, but could not query back. Please check system")
			}
		} else {
			log.Debugf("Failed to create inventory category for %s", errors.ErrorStack(err))
			return nil, errors.Trace(err)
		}
	}

	return id, nil
}

// DeleteTagIfNoObjectAttached checks to see if any objects are attached with this tag.
// If so, an error is thrown. Otherwise it deletes the tag and return any error encountered.
func (c *RestClient) DeleteTagIfNoObjectAttached(id string) error {
	objs, err := c.ListAttachedObjects(id)
	if err != nil {
		return errors.Trace(err)
	}
	if objs != nil && len(objs) > 0 {
		log.Debugf("tag %s related objects is not empty, do not delete it.", id)
		return nil
	}
	return c.DeleteTag(id)
}

// CreateTag takes in a TagCreateSpec pointer and calls VCloud API to create it.
// If a tag with the same name has been created in the category already, a bad request status code is returned.
func (c *RestClient) CreateTag(spec *TagCreateSpec) (*string, error) {
	log.Debugf("Create Tag %v", spec)
	stream, _, status, err := c.call(http.MethodPost, TagURL, spec, nil)

	log.Debugf("Get status code: %d", status)
	if status != http.StatusOK || err != nil {
		log.Debugf("Create tag failed with status code: %d, error message: %s", status, errors.ErrorStack(err))
		return nil, errors.Errorf("Status code: %d, error: %s", status, err)
	}

	type RespValue struct {
		Value string
	}

	var pId RespValue
	if err := json.NewDecoder(stream).Decode(&pId); err != nil {
		log.Debugf("Decode response body failed for: %s", errors.ErrorStack(err))
		return nil, errors.Trace(err)
	}
	return &(pId.Value), nil
}

// GetTag makes call to get information about the tag based on given id.
// If the tag id is invalid or client doesn't have the permission, an error is thrown.
func (c *RestClient) GetTag(id string) (*Tag, error) {
	log.Debugf("Get tag %s", id)

	stream, _, status, err := c.call(http.MethodGet, fmt.Sprintf("%s/id:%s", TagURL, id), nil, nil)

	if status != http.StatusOK || err != nil {
		log.Debugf("Get tag failed with status code: %s, error message: %s", status, errors.ErrorStack(err))
		return nil, errors.Errorf("Status code: %d, error: %s", status, err)
	}

	type RespValue struct {
		Value Tag
	}

	var pTag RespValue
	if err := json.NewDecoder(stream).Decode(&pTag); err != nil {
		log.Debugf("Decode response body failed for: %s", errors.ErrorStack(err))
		return nil, errors.Trace(err)
	}
	return &(pTag.Value), nil
}

// DeleteTag makes call to delete the tag based on id.
// If the tag id is invalid or client doesn't have the permission, an error is thrown.
func (c *RestClient) DeleteTag(id string) error {
	log.Debugf("Delete tag %s", id)

	_, _, status, err := c.call(http.MethodDelete, fmt.Sprintf("%s/id:%s", TagURL, id), nil, nil)

	if status != http.StatusOK || err != nil {
		log.Debugf("Delete tag failed with status code: %s, error message: %s", status, errors.ErrorStack(err))
		return errors.Errorf("Status code: %d, error: %s", status, err)
	}
	return nil
}

// ListTags makes call to list all the existing tags in all categories.
func (c *RestClient) ListTags() ([]string, error) {
	log.Debugf("List all tags")

	stream, _, status, err := c.call(http.MethodGet, TagURL, nil, nil)

	if status != http.StatusOK || err != nil {
		log.Debugf("Get tags failed with status code: %s, error message: %s", status, errors.ErrorStack(err))
		return nil, errors.Errorf("Status code: %d, error: %s", status, err)
	}

	return c.handleTagIdList(stream)
}

// ListTags makes call to list all the existing tags in the given category.
// If category id is invalid, an error is thrown.
func (c *RestClient) ListTagsForCategory(id string) ([]string, error) {
	log.Debugf("List tags for category: %s", id)

	type PostCategory struct {
		CId string `json:"category_id"`
	}
	spec := PostCategory{id}
	stream, _, status, err := c.call(http.MethodPost, fmt.Sprintf("%s/id:%s?~action=list-tags-for-category", TagURL, id), spec, nil)

	if status != http.StatusOK || err != nil {
		log.Debugf("List tags for category failed with status code: %s, error message: %s", status, errors.ErrorStack(err))
		return nil, errors.Errorf("Status code: %d, error: %s", status, err)
	}

	return c.handleTagIdList(stream)
}

func (c *RestClient) handleTagIdList(stream io.ReadCloser) ([]string, error) {
	type Tags struct {
		Value []string
	}

	var pTags Tags
	if err := json.NewDecoder(stream).Decode(&pTags); err != nil {
		log.Debugf("Decode response body failed for: %s", errors.ErrorStack(err))
		return nil, errors.Trace(err)
	}
	return pTags.Value, nil
}

// GetTagByNameForCategory gets tag through tag name and category id.
// If either parameter is invalid, an error is thrown.
func (c *RestClient) GetTagByNameForCategory(name string, id string) ([]Tag, error) {
	log.Debugf("Get tag %s for category %s", name, id)
	tagIds, err := c.ListTagsForCategory(id)
	if err != nil {
		log.Debugf("Get tag failed for %s", errors.ErrorStack(err))
		return nil, errors.Trace(err)
	}

	var tags []Tag
	for _, tId := range tagIds {
		tag, err := c.GetTag(tId)
		if err != nil {
			log.Debugf("Get tag %s failed for %s", tId, errors.ErrorStack(err))
			return nil, errors.Trace(err)
		}
		if tag.Name == name {
			tags = append(tags, *tag)
		}
	}
	return tags, nil
}

// GetAttachedTagsByNamePattern gets attached tags through tag name pattern
func (c *RestClient) GetAttachedTagsByNamePattern(namePattern string, objId string, objType string) ([]Tag, error) {
	tagIds, err := c.ListAttachedTags(objId, objType)
	if err != nil {
		log.Debugf("Get attached tags failed for %s", errors.ErrorStack(err))
		return nil, errors.Trace(err)
	}

	var validName = regexp.MustCompile(namePattern)
	var tags []Tag
	for _, tId := range tagIds {
		tag, err := c.GetTag(tId)
		if err != nil {
			log.Debugf("Get tag %s failed for %s", tId, errors.ErrorStack(err))
		}
		if validName.MatchString(tag.Name) {
			tags = append(tags, *tag)
		}
	}
	return tags, nil
}
