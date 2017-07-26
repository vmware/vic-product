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
	"net/http"
	"strings"

	log "github.com/Sirupsen/logrus"

	"github.com/vmware/vic/pkg/errors"
)

const (
	CategoryURL = "/com/vmware/cis/tagging/category"
)

type CategoryCreateSpec struct {
	CreateSpec CategoryCreate `json:"create_spec"`
}

type CategoryCreate struct {
	AssociableTypes []string `json:"associable_types"`
	Cardinality     string   `json:"cardinality"`
	Description     string   `json:"description"`
	Name            string   `json:"name"`
}

type Category struct {
	Id              string   `json:"id"`
	Description     string   `json:"description"`
	Name            string   `json:"name"`
	Cardinality     string   `json:"cardinality"`
	AssociableTypes []string `json:"associable_types"`
	UsedBy          []string `json:"used_by"`
}

// CreateCategoryIfNotExist takes in specs needed and query for the category first.
// If the given category has been created, it returns the category id and no error.
// Otherwise it creates the category and returns the category id and any error encountered.
func (c *RestClient) CreateCategoryIfNotExist(name string, description string, categoryType string, multiValue bool) (*string, error) {
	categories, err := c.GetCategoriesByName(name)
	if err != nil {
		log.Errorf("Failed to query category %s for: ", name, errors.ErrorStack(err))
		return nil, errors.Trace(err)
	}

	if categories == nil {
		var multiValueStr string
		if multiValue {
			multiValueStr = "MULTIPLE"
		} else {
			multiValueStr = "SINGLE"
		}
		categoryCreate := CategoryCreate{[]string{categoryType}, multiValueStr, description, name}
		spec := CategoryCreateSpec{categoryCreate}
		id, err := c.CreateCategory(&spec)
		if err != nil {
			// in case there are two docker daemon try to create inventory category, query the category once again
			if strings.Contains(err.Error(), "already_exists") {
				if categories, err = c.GetCategoriesByName(name); err != nil {
					log.Debugf("Failed to get inventory category for %s", errors.ErrorStack(err))
					return nil, errors.Trace(err)
				}
			} else {
				log.Debugf("Failed to create inventory category for %s", errors.ErrorStack(err))
				return nil, errors.Trace(err)
			}
		} else {
			return id, nil
		}
	}
	if categories != nil {
		return &categories[0].Id, nil
	}
	// should not happen
	log.Debugf("Failed to create inventory for it's existed, but could not query back. Please check system")
	return nil, errors.Errorf("Failed to create inventory for it's existed, but could not query back. Please check system")
}

// CreateCategory takes in a CategoryCreateSpec pointer and calls VCloud API to create it.
// If a category with the same name has been created already, a bad request status code is returned.
func (c *RestClient) CreateCategory(spec *CategoryCreateSpec) (*string, error) {
	log.Debugf("Create category %v", spec)
	stream, _, status, err := c.call(http.MethodPost, CategoryURL, spec, nil)

	log.Debugf("Get status code: %d", status)
	if status != http.StatusOK || err != nil {
		log.Debugf("Create category failed with status code: %d, error message: %s", status, errors.ErrorStack(err))
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

// GetCategory makes call to get information about the category based on id.
// If the category id is invalid or client doesn't have the permission, an error is thrown.
func (c *RestClient) GetCategory(id string) (*Category, error) {
	log.Debugf("Get category %s", id)

	stream, _, status, err := c.call(http.MethodGet, fmt.Sprintf("%s/id:%s", CategoryURL, id), nil, nil)

	if status != http.StatusOK || err != nil {
		log.Debugf("Get category failed with status code: %s, error message: %s", status, errors.ErrorStack(err))
		return nil, errors.Errorf("Status code: %d, error: %s", status, err)
	}

	type RespValue struct {
		Value Category
	}

	var pCategory RespValue
	if err := json.NewDecoder(stream).Decode(&pCategory); err != nil {
		log.Debugf("Decode response body failed for: %s", errors.ErrorStack(err))
		return nil, errors.Trace(err)
	}
	return &(pCategory.Value), nil
}

// DeleteCategory makes call to delete the category based on id.
// If the category id is invalid or client doesn't have the permission, an error is thrown.
func (c *RestClient) DeleteCategory(id string) error {
	log.Debugf("Delete category %s", id)

	_, _, status, err := c.call(http.MethodDelete, fmt.Sprintf("%s/id:%s", CategoryURL, id), nil, nil)

	if status != http.StatusOK || err != nil {
		log.Debugf("Delete category failed with status code: %s, error message: %s", status, errors.ErrorStack(err))
		return errors.Errorf("Status code: %d, error: %s", status, err)
	}
	return nil
}

// ListCategory makes call to list all the existing categories.
func (c *RestClient) ListCategories() ([]string, error) {
	log.Debugf("List all categories")

	stream, _, status, err := c.call(http.MethodGet, CategoryURL, nil, nil)

	if status != http.StatusOK || err != nil {
		log.Debugf("Get categories failed with status code: %s, error message: %s", status, errors.ErrorStack(err))
		return nil, errors.Errorf("Status code: %d, error: %s", status, err)
	}

	type Categories struct {
		Value []string
	}

	var pCategories Categories
	if err := json.NewDecoder(stream).Decode(&pCategories); err != nil {
		log.Debugf("Decode response body failed for: %s", errors.ErrorStack(err))
		return nil, errors.Trace(err)
	}
	return pCategories.Value, nil
}

// GetCategoriesByName gets all the existing categories and compare their name with the name given.
// All categories that matches the given name are returned.
func (c *RestClient) GetCategoriesByName(name string) ([]Category, error) {
	log.Debugf("Get category %s", name)
	categoryIds, err := c.ListCategories()
	if err != nil {
		log.Debugf("Get category failed for: %s", errors.ErrorStack(err))
		return nil, errors.Trace(err)
	}

	var categories []Category
	for _, cId := range categoryIds {
		category, err := c.GetCategory(cId)
		if err != nil {
			log.Debugf("Get category %s failed for %s", cId, errors.ErrorStack(err))
		}
		if category.Name == name {
			categories = append(categories, *category)
		}
	}
	return categories, nil
}
