package lib

import (
	"context"
	"net/url"

	log "github.com/sirupsen/logrus"

	"github.com/vmware/vic/pkg/trace"
	"github.com/vmware/vic/lib/install/validate"
	"github.com/vmware/vic/lib/install/data"
)

type LoginInfo struct {
	Target          string `json:"target"`
	User            string `json:"user"`
	Password        string `json:"password"`
	Validator       *validate.Validator
}

// Verify login based on info given, return non nil error if validation fails.
func (info *LoginInfo) VerifyLogin() error {
	defer trace.End(trace.Begin(""))

	ctx := context.TODO()

	var u url.URL
	u.User = url.UserPassword(info.User, info.Password)
	u.Host = info.Target
	u.Path = ""
	log.Infof("server URL: %v\n", u)

	input := data.NewData()

	username := u.User.Username()
	input.OpsCredentials.OpsUser = &username
	passwd, _ := u.User.Password()
	input.OpsCredentials.OpsPassword = &passwd
	input.URL = &u
	input.Force = true

	input.User = username
	input.Password = &passwd

	v, err := validate.NewValidator(ctx, input)
	if err != nil {
		log.Infof("validator: %s", err)
		return err
	}

	info.Validator = v

	return nil
}
