@{
    AllNodes =
    @(
        @{ 
	   NodeName="*"
           PSDscAllowPlainTextPassword = $true
        },

	@{ 
	   NodeName = 'firstform-ppd1.gksm.local'
	   Role     = "Test"
        },

	@{ 
	   NodeName = 'Firstform-sql1.gksm.local'
	   Role     = "Test"
        },

	@{ 
	   NodeName = 'firstform-job1.gksm.local'
	   Role     = "Test"
        },

	@{ 
	   NodeName = 'sm-saperion-tst.gksm.local'
	   Role     = "Test"
        },

	@{ 
	   NodeName = 'saperion-dev.gksm.local'
	   Role     = "Test"
        },

	@{ 
	   NodeName = 'saperion-mssql.gksm.local'
	   Role     = "Test"
        },

	@{ 
	   NodeName = 'saperion2-gate.gksm.local'
	   Role     = "Test"
        },

	@{ 
	   NodeName = 'kofaxmain.gksm.local'
	   Role     = "Test"
        },

	@{ 
	   NodeName = 'kofax-lic.gksm.local'
	   Role     = "Test"
        },

	 @{ 
	   NodeName = 'kofaxapp2.gksm.local'
	   Role     = "Test"
        },

	@{ 
	   NodeName = 'kofaxapp.gksm.local'
	   Role     = "Test"
        },

	@{ 
	   NodeName = 'kofax-test.gksm.local'
	   Role     = "Test"
        },

	@{ 
	   NodeName = 'Bpm-elma-test.gksm.local'
	   Role     = "Test"
        },

	@{ 
	   NodeName = 'enovia-mcs1.gksm.local'
	   Role     = "Test"
        },

	@{ 
	   NodeName = 'enovia-mcs2.gksm.local'
	   Role     = "Test"
        },

	@{ 
	   NodeName = 'enovia-fcs1.gksm.local'
	   Role     = "Test"
        },

	@{ 
	   NodeName = 'enovia-fcs2.gksm.local'
	   Role     = "Test"
        },

	@{ 
	   NodeName = 'sm-enovia-dev.gksm.local'
	   Role     = "Test"
        },

	@{ 
	   NodeName = 'enovia-mcs-test.gksm.local'
	   Role     = "Test"
        }

    )
}