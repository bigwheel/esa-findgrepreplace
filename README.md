## Execution example

```bash
./esa-findgrepreplace.sh $pat bigwheel-sms 'api.esa.io' 'api.esa.io.hogehoge' | while read --line json; echo "$json" | jq -r '"\(.url)/revisions/\(.revision_number)"'; end
```
