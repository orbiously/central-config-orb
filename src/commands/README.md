# Commands

### `dispatch-config`

#### Parameters:


| Name | Type | Description | Default | Required |
| ----------- | ----------- | ----------- | ----------- | ----------- |
| force-update | boolean | Dispatch config even if the same verison is already present in target repo/branch | false | No |
| skip-build-on-targets   | boolean | Skip build in target projects upon config push | true | No |
| config-to-deploy   | string | Configuration file to be deployed to all targets | _no default value_ | **Yes** |
| targets-list   | string | JSON file containing the list of repo and branch targets. Each target is defined as a JSON object | _no default value_ | **Yes** |
