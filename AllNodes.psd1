@{
    AllNodes =
    @(
        @{ 
	   NodeName="*"
           PSDscAllowPlainTextPassword = $true
        },
	
	@{ 
	   NodeName = '1c-lic01.gksm.local'
	   Role     = "1CServer"
        },

        @{ 
	   NodeName = '1c-lic02.gksm.local'
	   Role     = "1CServer"
        }#,

#        @{ NodeName = '1c-ut-test.gksm.local'
#        },

#        @{ NodeName = '1ctestbit.gksm.local'
#        },

#        @{ NodeName = '1c-ut-cluster3.gksm.local'
#        },

#        @{ NodeName = '1c-ut-cluster4.gksm.local'
#        }
    )
}