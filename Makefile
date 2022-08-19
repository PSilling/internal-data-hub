PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

getmembers = $(shell \
	ldapsearch -x -H ldap://ldap.corp.redhat.com -LLL -b 'ou=adhoc,ou=managedGroups,dc=redhat,dc=com' 'cn=$(1)' \
	|grep uniqueMember \
	|sed "s/.*uid=\([^,]*\),.*/\1/g" \
	|sort \
	|paste -sd "," \
	|awk '{print "$(1):"$$1}')

updatemembers = $(shell sed -i "s/^$(1):.*$$/$(call getmembers,$(1))/" kfdefs/base/trino/trino-group-mapping.properties)

CCX_SENSITIVE := $(shell \
	ldapsearch -x -H ldap://ldap.corp.redhat.com -LLL -b 'ou=adhoc,ou=managedGroups,dc=redhat,dc=com' 'cn=ccx-sensitive-datalake-access' \
	|grep uniqueMember \
	|sed "s/.*uid=\([^,]*\),.*/\1/g" \
	|sort \
	|paste -sd "," \
	|awk '{print "ccx-sensitive-datalake-access:superset-ccx-sensitive,"$$1}')
CCX := $(shell \
	ldapsearch -x -H ldap://ldap.corp.redhat.com -LLL -b 'ou=adhoc,ou=managedGroups,dc=redhat,dc=com' 'cn=ccx-datalake-access' \
	|grep uniqueMember \
	|sed "s/.*uid=\([^,]*\),.*/\1/g" \
	|sort \
	|paste -sd "," \
	|awk '{print "ccx-datalake-access:superset-ccx,"$$1}')
CCX_SREP := $(shell \
	ldapsearch -x -H ldap://ldap.corp.redhat.com -LLL -b 'ou=adhoc,ou=managedGroups,dc=redhat,dc=com' 'cn=ccx-srep-data-access' \
	|grep uniqueMember \
	|sed "s/.*uid=\([^,]*\),.*/\1/g" \
	|sort \
	|paste -sd "," \
	|awk '{print "ccx-srep-data-access:"$$1}')

update-trino-groups: ## Update trino access groups from LDAP
	$(call updatemembers,data-hub-openshift-admins)
	$(call updatemembers,ccx-dev)
	@sed -i "s/^ccx-sensitive-datalake-access:.*$$/$(CCX_SENSITIVE)/" kfdefs/base/trino/trino-group-mapping.properties
	@sed -i "s/^ccx-datalake-access:.*$$/$(CCX)/" kfdefs/base/trino/trino-group-mapping.properties
	@sed -i "s/^ccx-srep-data-access:.*$$/$(CCX_SREP)/" kfdefs/base/trino/trino-group-mapping.properties
	$(call updatemembers,telemeter-auth)
	$(call updatemembers,telemeter-manual-approval)
	$(call updatemembers,telemeter-auto-approval)

	$(call updatemembers,ceeandpe)
	$(call updatemembers,na-cs-tam-auto)
	$(call updatemembers,apac-cs-tam-auto)
	$(call updatemembers,latam-cs-tam-auto)
	$(call updatemembers,emea-cs-tam-auto)
	$(call updatemembers,na-ps-cs-tam-auto)
	$(call updatemembers,emea-cs-csm-auto)
	$(call updatemembers,emea-cs-cse-auto)
	$(call updatemembers,emea-cs-managers)
	$(call updatemembers,apac-cs-csm-auto)
	$(call updatemembers,apac-cs-cse-auto)
	$(call updatemembers,na-cs-csm-auto)
	$(call updatemembers,na-cs-cse-auto)
	$(call updatemembers,na-ps-cs-cse-auto)
	$(call updatemembers,latam-cs-csm-auto)
	$(call updatemembers,ccx-pm)
	$(call updatemembers,assisted-lakers)
	$(call updatemembers,cide-insights)
	$(call updatemembers,cide-warehouse-trino-access)
	$(call updatemembers,cide-digests-trino-access)
