# Commands

### `dispatch-config`

#### Parameters:


| Name | Type | Description | Default | Required |
| ----------- | ----------- | ----------- | ----------- | ----------- |
| force-update | boolean | Dispatch config even if the same verison is already present in target repo/branch | false | No |
| skip-build-on-targets   | boolean | Skip build in target projects upon config push | true | No |
| config-to-deploy   | string | Configuration file to be deployed to all targets | _no default value_ | **Yes** |
| targets-list   | string | JSON file containing the list of target repositories+branches. Each target is defined as a JSON object | _no default value_ | **Yes** |


#### Example of targets list file:

```
{
    "target-repo": "repo_name_1",
    "target-branch": "branch_name"
}
{
    "target-repo": "repo_name_2",
    "target-branch": "custom-webhook"
}
```
