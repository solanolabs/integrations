# Solano CI Integrations

[![](https://ci.solanolabs.com:443/solanolabs/integrations/badges/187235.png)](https://ci.solanolabs.com:443/solanolabs/integrations/suites/187235)

## Webhooks

### Gerrit

`gerrit/patchset-created` implements a sample Gerrit patchset-created hook to
notify Solano CI when a Gerrit review is updated with new changes.

If you want to use this script as-is, You should fill in or replace the
following constants within the script based on your installation:

- GERRIT_API_PREFIX
- SOLANO_CI_REPO_ENDPOINTS

See comments within the script for more information.
