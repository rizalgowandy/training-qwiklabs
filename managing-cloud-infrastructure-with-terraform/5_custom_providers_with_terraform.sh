#!/usr/bin/env bash

cat <<EOF >provider.go
package main

import (
        "github.com/hashicorp/terraform/helper/schema"
)

func Provider() *schema.Provider {
        return &schema.Provider{
                ResourcesMap: map[string]*schema.Resource{
                        "example_server": resourceServer(),
                },
        }
}
EOF

cat <<EOF >main.go
package main

import (
        "github.com/hashicorp/terraform/plugin"
        "github.com/hashicorp/terraform/terraform"
)

func main() {
        plugin.Serve(&plugin.ServeOpts{
                ProviderFunc: func() terraform.ResourceProvider {
                        return Provider()
                },
        })
}
EOF

go mod init gopath/src/github.com/hashicorp/terraform
go get github.com/hashicorp/terraform/helper/schema
go get github.com/hashicorp/terraform/plugin
go get github.com/hashicorp/terraform/terraform
go build -o terraform-provider-example

ls

./terraform-provider-example

cat <<EOF >resource_server.go
package main

import (
        "github.com/hashicorp/terraform/helper/schema"
)

func resourceServer() *schema.Resource {
        return &schema.Resource{
                Create: resourceServerCreate,
                Read:   resourceServerRead,
                Update: resourceServerUpdate,
                Delete: resourceServerDelete,

                Schema: map[string]*schema.Schema{
                        "address": &schema.Schema{
                                Type:     schema.TypeString,
                                Required: true,
                        },
                },
        }
}

func resourceServerCreate(d *schema.ResourceData, m interface{}) error {
        address := d.Get("address").(string)
        d.SetId(address)
        return nil
}

func resourceServerRead(d *schema.ResourceData, m interface{}) error {
  client := m.(*MyClient)

  // Attempt to read from an upstream API
  obj, ok := client.Get(d.Id())

  // If the resource does not exist, inform Terraform. We want to immediately
  // return here to prevent further processing.
  if !ok {
    d.SetId("")
    return nil
  }

  d.Set("address", obj.Address)
  return nil
}

func resourceServerUpdate(d *schema.ResourceData, m interface{}) error {
        // Enable partial state mode
        d.Partial(true)

        if d.HasChange("address") {
                // Try updating the address
                if err := updateAddress(d, m); err != nil {
                        return err
                }

                d.SetPartial("address")
        }

        // If we were to return here, before disabling partial mode below,
        // then only the "address" field would be saved.

        // We succeeded, disable partial mode. This causes Terraform to save
        // all fields again.
        d.Partial(false)

        return nil
}

func resourceServerDelete(d *schema.ResourceData, m interface{}) error {
  // d.SetId("") is automatically called assuming delete returns no errors, but
  // it is added here for explicitness.
        d.SetId("")
        return nil
}
EOF

go build -o terraform-provider-example
./terraform-provider-example

cat <<EOF >main.tf
resource "example_server" "my-server" {
  address = "1.2.3.4"
}
EOF

terraform init
terraform plan
terraform apply
