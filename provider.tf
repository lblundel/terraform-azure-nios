provider "azurerm" {
  features {
    virtual_machine {
      skip_shutdown_and_force_delete = true
    }
  }
  use_msi                         = false
  use_cli                         = true
  use_oidc                        = false
  environment                     = "public"
}
