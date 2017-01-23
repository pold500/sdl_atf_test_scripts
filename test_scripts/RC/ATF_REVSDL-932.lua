local commonSteps = require("user_modules/shared_testcases/commonSteps")
commonSteps:DeleteLogsFileAndPolicyTable()

revsdl = require("user_modules/revsdl")

revsdl.AddUnknownFunctionIDs()
revsdl.SubscribeToRcInterface()
config.ValidateSchema = false

config.application1.registerAppInterfaceParams.appHMIType = { "REMOTE_CONTROL" }

Test = require('connecttest')
require('cardinalities')
local events = require('events')
local mobile_session = require('mobile_session')
local mobile  = require('mobile_connection')
local tcp = require('tcp_connection')
local file_connection  = require('file_connection')
local config = require('config')
local module = require('testbase')





---------------------------------------------------------------------------------------------
-------------------------------------STARTING COMMON FUNCTIONS-------------------------------
---------------------------------------------------------------------------------------------

--Create ModuleType for maxsize=1000. Using to perform test moduleType OverUpperBound case.
-------strModuleType<String>: "RADIO" or "CLIMATE"
-------iMaxsize<Integer>	: the length or array
local function CreateModuleTypes(strModuleType, iMaxsize)
	local items = {}
	for i=1, iMaxsize do
		table.insert(items, i, strModuleType)
	end
	return items
end

---------------------------------------------------------------------------------------------
----------------------------------------END COMMON FUNCTIONS---------------------------------
---------------------------------------------------------------------------------------------




---------------------------------------------------------------------------------------------
-------------------------------------------Preconditions-------------------------------------
---------------------------------------------------------------------------------------------
	--Begin Precondition.1. Need to be uncomment for checking Driver's device case
	--[[Description: Activation App by sending SDL.ActivateApp

		function Test:WaitActivation()

			--mobile side: Expect OnHMIStatus notification
			EXPECT_NOTIFICATION("OnHMIStatus")

			--hmi side: sending SDL.ActivateApp request
			local rid = self.hmiConnection:SendRequest("SDL.ActivateApp",
														{ appID = self.applications["Test Application"] })

			--hmi side: send request RC.OnSetDriversDevice
			self.hmiConnection:SendNotification("RC.OnSetDriversDevice",
			{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})

			--hmi side: Waiting for SDL.ActivateApp response
			EXPECT_HMIRESPONSE(rid)

		end]]
	--End Precondition.1

	-----------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------
-------------------------REVSDL-932: App's RPCs validation rules-----------------------------
---Check: RSDL validate each and every RPC that app sends per "Remote-Control-Mobile-API"----
---------------------------------------------------------------------------------------------
	--Begin Test suit CommonRequestCheck

	--Description: TC's checks processing
		-- mandatory param is missing
		-- param has an out-of-bounds value
		-- invalid json
		-- string param with invalid characters
		-- param of wrong type



--=================================================BEGIN TEST CASES 1==========================================================--
	--Begin Test suit CommonRequestCheck.1 for ButtonPress

	--Description: Validation App's RPC for ButtonPress request

	--Begin Test case CommonRequestCheck.1
	--Description: 	--mandatory param is missing
					--[REVSDL-932]: 2. Mandatory params missing

		--Requirement/Diagrams id in jira:
				--REVSDL-932
				--REVSDL-937
				--https://adc.luxoft.com/jira/secure/attachment/115807/115807_Req_1_2_of_REVSDL-932.png

		--Verification criteria:
				--In case app sends RPC with one or more mandatory-by-mobile_API parameters missing, RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app

			--Begin Test case CommonRequestCheck.1.1
			--Description: ButtonPress with all parameters missing
				function Test:ButtonPress_AllParamsMissing()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.2
			--Description: ButtonPress with Colspan parameter missing
				function Test:ButtonPress_ColspanMissing()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							row = 1,
							rowspan = 1,
							col = 1,
							levelspan = 1,
							level = 1
						},
						moduleType = "CLIMATE",
						buttonPressMode = "LONG",
						buttonName = "AC_MAX"
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.3
			--Description: ButtonPress with row parameter missing
				function Test:ButtonPress_RowMissing()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 1,
							rowspan = 1,
							col = 1,
							levelspan = 1,
							level = 1
						},
						moduleType = "CLIMATE",
						buttonPressMode = "LONG",
						buttonName = "AC_MAX"
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.3

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.4
			--Description: ButtonPress with rowspan parameter missing
				function Test:ButtonPress_RowspanMissing()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							col = 1,
							levelspan = 1,
							level = 1
						},
						moduleType = "RADIO",
						buttonPressMode = "LONG",
						buttonName = "AC_MAX"
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.4

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.5
			--Description: ButtonPress with col parameter missing
				function Test:ButtonPress_ColMissing()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							rowspan = 1,
							levelspan = 1,
							level = 1
						},
						moduleType = "RADIO",
						buttonPressMode = "SHORT",
						buttonName = "AC_MAX"
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.5

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.6
			--Description: ButtonPress with levelspan parameter missing
				function Test:ButtonPress_LevelspanMissing()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							rowspan = 1,
							col = 1,
							level = 1
						},
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
						buttonName = "AC_MAX"
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.6

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.7
			--Description: ButtonPress with level parameter missing
				function Test:ButtonPress_levelMissing()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							rowspan = 1,
							col = 1,
							levelspan = 1
						},
						moduleType = "CLIMATE",
						buttonPressMode = "LONG",
						buttonName = "AC_MAX"
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.7

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.8
			--Description: ButtonPress with moduleType parameter missing
				function Test:ButtonPress_ModuleTypeMissing()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							rowspan = 1,
							col = 1,
							levelspan = 1,
							level = 1
						},
						buttonPressMode = "LONG",
						buttonName = "AC_MAX"
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.8

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.9
			--Description: ButtonPress with buttonPressMode parameter missing
				function Test:ButtonPress_ButtonPressModeMissing()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							rowspan = 1,
							col = 1,
							levelspan = 1,
							level = 1
						},
						moduleType = "CLIMATE",
						buttonName = "AC_MAX"
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.9

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.10
			--Description: ButtonPress with buttonName parameter missing
				function Test:ButtonPress_ButtonNameMissing()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							rowspan = 1,
							col = 1,
							levelspan = 1,
							level = 1
						},
						moduleType = "CLIMATE",
						buttonPressMode = "LONG",
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.10

			--Begin Test case CommonRequestCheck.1.11
			--Description: ButtonPress with zone parameter missing
				function Test:ButtonPress_ZoneMissing()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						moduleType = "CLIMATE",
						buttonPressMode = "LONG",
						buttonName = "AC_MAX"
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.11

			--Begin Test case CommonRequestCheck.1.12
			--Description: ButtonPress with rowspan and buttonPressMode parameters missing
				function Test:ButtonPress_RowspanAndButtonPressModeMissing()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							col = 1,
							levelspan = 1,
							level = 1
						},
						moduleType = "CLIMATE",
						buttonName = "AC_MAX"
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.12

	--End Test case CommonRequestCheck.1

		-----------------------------------------------------------------------------------------

	--Begin Test case CommonRequestCheck.2
	--Description: 	--param has an out-of-bounds value
					--[REVSDL-932]: 3 Parameters out of bounds

		--Requirement/Diagrams id in jira:
				--REVSDL-932
				--REVSDL-938
				--https://adc.luxoft.com/jira/secure/attachment/115809/115809_Req_1_3_of_REVSDL-932.png

		--Verification criteria:
				--In case app sends RPC with one or more mandatory or non-mandatory by-mobile_API parameters out of bounds, RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app

			--Begin Test case CommonRequestCheck.2.1
			--Description: ButtonPress with all parameters out of bounds
				function Test:ButtonPress_AllParametersOutLowerBound()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = -1,
							row = -1,
							rowspan = -1,
							col = -1,
							levelspan = -1,
							level = -1
						},
						moduleType = "CLIMATE",
						buttonPressMode = "LONG",
						buttonName = "AC_MAX"
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.2
			--Description: ButtonPress with Colspan parameter out of bounds
				function Test:ButtonPress_ColspanOutLowerBound()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = -1,
							row = 1,
							rowspan = 1,
							col = 1,
							levelspan = 1,
							level = 1
						},
						moduleType = "CLIMATE",
						buttonPressMode = "LONG",
						buttonName = "AC_MAX"
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.3
			--Description: ButtonPress with row parameter out of bounds
				function Test:ButtonPress_RowOutLowerBound()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 1,
							row = -1,
							rowspan = 1,
							col = 1,
							levelspan = 1,
							level = 1
						},
						moduleType = "CLIMATE",
						buttonPressMode = "LONG",
						buttonName = "AC_MAX"
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.3

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.4
			--Description: ButtonPress with rowspan parameter out of bounds
				function Test:ButtonPress_RowspanOutLowerBound()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							rowspan = -1,
							col = 1,
							levelspan = 1,
							level = 1
						},
						moduleType = "CLIMATE",
						buttonPressMode = "LONG",
						buttonName = "AC_MAX"
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.4

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.5
			--Description: ButtonPress with col parameter out of bounds
				function Test:ButtonPress_ColOutLowerBound()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							rowspan = 1,
							col = -1,
							levelspan = 1,
							level = 1
						},
						moduleType = "CLIMATE",
						buttonPressMode = "LONG",
						buttonName = "AC_MAX"
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.5

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.6
			--Description: ButtonPress with levelspan parameter out of bounds
				function Test:ButtonPress_LevelspanOutLowerBound()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							rowspan = 1,
							col = 1,
							levelspan = -1,
							level = 1
						},
						moduleType = "CLIMATE",
						buttonPressMode = "LONG",
						buttonName = "AC_MAX"
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.6

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.7
			--Description: ButtonPress with level parameter out of bounds
				function Test:ButtonPress_LevelOutLowerBound()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							rowspan = 1,
							col = 1,
							levelspan = 1,
							level = -1
						},
						moduleType = "CLIMATE",
						buttonPressMode = "LONG",
						buttonName = "AC_MAX"
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.7

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.8
			--Description: ButtonPress with all parameters out of bounds
				function Test:ButtonPress_AllParametersOutUpperBound()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 101,
							row = 101,
							rowspan = 101,
							col = 101,
							levelspan = 101,
							level = 101
						},
						moduleType = "CLIMATE",
						buttonPressMode = "LONG",
						buttonName = "AC_MAX"
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.8

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.9
			--Description: ButtonPress with Colspan parameter out of bounds
				function Test:ButtonPress_ColspanOutUpperBound()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 101,
							row = 1,
							rowspan = 1,
							col = 1,
							levelspan = 1,
							level = 1
						},
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
						buttonName = "AC_MAX"
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.9

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.10
			--Description: ButtonPress with row parameter out of bounds
				function Test:ButtonPress_RowOutUpperBound()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 1,
							row = 101,
							rowspan = 1,
							col = 1,
							levelspan = 1,
							level = 1
						},
						moduleType = "CLIMATE",
						buttonPressMode = "LONG",
						buttonName = "AC_MAX"
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.10

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.11
			--Description: ButtonPress with rowspan parameter out of bounds
				function Test:ButtonPress_RowspanOutUpperBound()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							rowspan = 101,
							col = 1,
							levelspan = 1,
							level = 1
						},
						moduleType = "CLIMATE",
						buttonPressMode = "LONG",
						buttonName = "AC_MAX"
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.11

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.12
			--Description: ButtonPress with col parameter out of bounds
				function Test:ButtonPress_ColOutUpperBound()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							rowspan = 1,
							col = 101,
							levelspan = 1,
							level = 1
						},
						moduleType = "CLIMATE",
						buttonPressMode = "LONG",
						buttonName = "AC_MAX"
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.12

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.13
			--Description: ButtonPress with levelspan parameter out of bounds
				function Test:ButtonPress_LevelspanOutUpperBound()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							rowspan = 1,
							col = 1,
							levelspan = 101,
							level = 1
						},
						moduleType = "CLIMATE",
						buttonPressMode = "LONG",
						buttonName = "AC_MAX"
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.13

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.14
			--Description: ButtonPress with level parameter out of bounds
				function Test:ButtonPress_LevelOutUpperBound()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							rowspan = 1,
							col = 1,
							levelspan = 1,
							level = 101
						},
						moduleType = "CLIMATE",
						buttonPressMode = "LONG",
						buttonName = "AC_MAX"
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.14

	--End Test case CommonRequestCheck.2

		-----------------------------------------------------------------------------------------

	--Begin Test case CommonRequestCheck.3
	--Description: 	--invalid json
					--[REVSDL-932]: 4. Wrong json

		--Requirement/Diagrams id in jira:
				--REVSDL-932
				--REVSDL-939
				--https://adc.luxoft.com/jira/secure/attachment/115813/115813_Req_1_4_REVSDL-932.png

		--Verification criteria:
				--In case app sends RPC in wrong JSON, RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app

			--Begin Test case CommonRequestCheck.3.1
			--Description: Request with invalid JSON syntax (INVALID_DATA)
				function Test:ButtonPress_InvalidJson()
				  self.mobileSession.correlationId = self.mobileSession.correlationId + 1

				  local msg =
				  {
					serviceType      = 7,
					frameInfo        = 0,
					rpcType          = 0,
					rpcFunctionId    = 100015,
					rpcCorrelationId = self.mobileSession.correlationId,
					payload          = '{"zone":{"colspan":1,"row":1,"rowspan":1,"col":1,"levelspan":1,"level":1},"moduleType":"CLIMATE","buttonPressMode":"LONG","buttonName" "AC_MAX"}'
				  }
				  self.mobileSession:Send(msg)
				  self.mobileSession:ExpectResponse(self.mobileSession.correlationId, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.3.1

	--End Test case CommonRequestCheck.3

		-----------------------------------------------------------------------------------------

	--Begin Test case CommonRequestCheck.4
	--Description: 	--invalid json
					--[REVSDL-932]: 5. String with invalid characters

		--Requirement/Diagrams id in jira:
				--REVSDL-932
				--REVSDL-940
				--https://adc.luxoft.com/jira/secure/attachment/115818/115818_Req_1_5_of_REVSDL-932.png

		--Verification criteria:
				--In case app sends RPC with invalid characters in param of string type, RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app

		--SKIPPED because "Note: currently none of the listed RPCs has a string param." cloned to REVSDL-1005 [REVSDL-932]: 6. Parameter of wrong type

	--End Test case CommonRequestCheck.4

		-----------------------------------------------------------------------------------------

	--Begin Test case CommonRequestCheck.5
	--Description: 	--param of wrong type
					--[REVSDL-932]: 6. Parameter of wrong type

		--Requirement/Diagrams id in jira:
				--REVSDL-932
				--REVSDL-941
				--https://adc.luxoft.com/jira/secure/attachment/115819/115819_Req_1_6_of_REVSDL-932.png

		--Verification criteria:
				--In case app sends RPC with param of wrong type, RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app

			--Begin Test case CommonRequestCheck.5.1
			--Description: ButtonPress with all parameters of wrong type
				function Test:ButtonPress_AllParamsWrongType()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = "1",
							row = "1",
							rowspan = "1",
							col = "1",
							levelspan = "1",
							level = "1"
						},
						moduleType = 111,
						buttonPressMode = 111,
						buttonName = 111
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.2
			--Description: ButtonPress with Colspan parameter of wrong type
				function Test:ButtonPress_ColspanWrongType()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = "1",
							row = 1,
							rowspan = 1,
							col = 1,
							levelspan = 1,
							level = 1
						},
						moduleType = "CLIMATE",
						buttonPressMode = "LONG",
						buttonName = "AC_MAX"
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.3
			--Description: ButtonPress with row parameter of wrong type
				function Test:ButtonPress_RowWrongType()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 1,
							row = "1",
							rowspan = 1,
							col = 1,
							levelspan = 1,
							level = 1
						},
						moduleType = "CLIMATE",
						buttonPressMode = "LONG",
						buttonName = "AC_MAX"
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.3

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.4
			--Description: ButtonPress with rowspan parameter of wrong type
				function Test:ButtonPress_RowspanWrongType()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							rowspan = "1",
							col = 1,
							levelspan = 1,
							level = 1
						},
						moduleType = "CLIMATE",
						buttonPressMode = "LONG",
						buttonName = "AC_MAX"
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.4

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.5
			--Description: ButtonPress with col parameter of wrong type
				function Test:ButtonPress_ColWrongType()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							rowspan = 1,
							col = "1",
							levelspan = 1,
							level = 1
						},
						moduleType = "CLIMATE",
						buttonPressMode = "LONG",
						buttonName = "AC_MAX"
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.5

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.6
			--Description: ButtonPress with levelspan parameter of wrong type
				function Test:ButtonPress_LevelspanWrongType()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							rowspan = 1,
							col = 1,
							levelspan = "1",
							level = 1
						},
						moduleType = "CLIMATE",
						buttonPressMode = "LONG",
						buttonName = "AC_MAX"
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.6

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.7
			--Description: ButtonPress with level parameter of wrong type
				function Test:ButtonPress_levelWrongType()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							rowspan = 1,
							col = 1,
							levelspan = 1,
							level = "1"
						},
						moduleType = "CLIMATE",
						buttonPressMode = "LONG",
						buttonName = "AC_MAX"
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.7

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.8
			--Description: ButtonPress with moduleType parameter of wrong type
				function Test:ButtonPress_ModuleTypeWrongType()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							rowspan = 1,
							col = 1,
							levelspan = 1,
							level = 1
						},
						moduleType = 111,
						buttonPressMode = "LONG",
						buttonName = "AC_MAX"
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.8

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.9
			--Description: ButtonPress with buttonPressMode parameter of wrong type
				function Test:ButtonPress_ButtonPressModeWrongType()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							rowspan = 1,
							col = 1,
							levelspan = 1,
							level = 1
						},
						moduleType = "CLIMATE",
						buttonPressMode = 111,
						buttonName = "AC_MAX"
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.9

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.10
			--Description: ButtonPress with buttonName parameter of wrong type
				function Test:ButtonPress_ButtonNameWrongType()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							rowspan = 1,
							col = 1,
							levelspan = 1,
							level = 1
						},
						moduleType = "CLIMATE",
						buttonPressMode = "LONG",
						buttonName = 111
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.10

			--Begin Test case CommonRequestCheck.5.11
			--Description: ButtonPress with zone elements parameter of wrong type
				function Test:ButtonPress_ZoneElementsWrongType()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = "1",
							row = true,
							rowspan = false,
							col = 1,
							levelspan = "1",
							level = "abc"
						},
						moduleType = "CLIMATE",
						buttonPressMode = "LONG",
						buttonName = "AC_MAX"
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.11

			--Begin Test case CommonRequestCheck.5.12
			--Description: ButtonPress with rowspan and buttonPressMode parameters of wrong type
				function Test:ButtonPress_RowspanAndButtonPressModeWrongType()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							rowspan = "1",
							col = 1,
							levelspan = 1,
							level = 1
						},
						moduleType = "CLIMATE",
						buttonPressMode = true,
						buttonName = "AC_MAX"
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.12

			--Begin Test case CommonRequestCheck.5.13
			--Description: ButtonPress with zone parameter of wrong type
				function Test:ButtonPress_ZoneWrongType()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone = true,
						moduleType = "CLIMATE",
						buttonPressMode = "LONG",
						buttonName = "AC_MAX"
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.13

	--End Test case CommonRequestCheck.5

		-----------------------------------------------------------------------------------------

	--Begin Test case CommonRequestCheck.6
	--Description: 	--RSDL cuts off the fake param (non-existent per Mobile_API) from app's RPC.
					--[REVSDL-932]: 7. Fake params

		--Requirement/Diagrams id in jira:
				--REVSDL-932
				--REVSDL-997
				--https://adc.luxoft.com/jira/secure/attachment/116227/116227_Req_1_2_7_of_REVSDL-932.png

		--Verification criteria:
				--In case app sends RPC with fake param (non-existent per Mobile_API), RSDL must cut this param off from the RPC and then validate this RPC and process as assigned.

			--Begin Test case CommonRequestCheck.6.1
			--Description: app sends RPC with fake param inside zone
				function Test:ButtonPress_FakeParamsInsideZone()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							fake1 = true,
							colspan = 2,
							row = 0,
							rowspan = 2,
							fake2 = 1,
							col = 0,
							levelspan = 1,
							level = 0
						},
						moduleType = "CLIMATE",
						buttonPressMode = "LONG",
						buttonName = "AC_MAX"
					})

				--hmi side: expect Buttons.ButtonPress request
				EXPECT_HMICALL("Buttons.ButtonPress",
								{
									zone =
									{
										colspan = 2,
										row = 0,
										rowspan = 2,
										col = 0,
										levelspan = 1,
										level = 0
									},
									moduleType = "CLIMATE",
									buttonPressMode = "LONG",
									buttonName = "AC_MAX"
								})
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.6.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.6.2
			--Description: app sends RPC with fake param outside zone
				function Test:ButtonPress_FakeParamsOutsideZone()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 2,
							row = 0,
							rowspan = 2,
							col = 0,
							levelspan = 1,
							level = 0
						},
						fake1 = "RADIO",
						moduleType = "CLIMATE",
						buttonPressMode = "LONG",
						fake3 = false,
						buttonName = "AC_MAX"
					})

				--hmi side: expect Buttons.ButtonPress request
				EXPECT_HMICALL("Buttons.ButtonPress",
								{
									zone =
									{
										colspan = 2,
										row = 0,
										rowspan = 2,
										col = 0,
										levelspan = 1,
										level = 0
									},
									moduleType = "CLIMATE",
									buttonPressMode = "LONG",
									buttonName = "AC_MAX"
								})
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
					:ValidIf (function(_,data)
							if data.payload.fake1 then
								print(" SDL resend fake parameter to mobile app ")
								return false
							else
								return true
							end
					end)

				end
			--End Test case CommonRequestCheck.6.2
	--End Test case CommonRequestCheck.6

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.1

--=================================================END TEST CASES 1==========================================================--








--=================================================BEGIN TEST CASES 2==========================================================--
	--Begin Test suit CommonRequestCheck.2 for GetInteriorVehicleDataCapabilities

	--Description: Validation App's RPC for GetInteriorVehicleDataCapabilities request

	--Description: TC's checks processing
		-- mandatory param is missing
		-- param has an out-of-bounds value
		-- invalid json
		-- string param with invalid characters
		-- param of wrong type

	--Begin Test case CommonRequestCheck.1
	--Description: 	--mandatory param is missing
					--[REVSDL-932]: 2. Mandatory params missing

		--Requirement/Diagrams id in jira:
				--REVSDL-932
				--REVSDL-937
				--https://adc.luxoft.com/jira/secure/attachment/115807/115807_Req_1_2_of_REVSDL-932.png

		--Verification criteria:
				--In case app sends RPC with one or more mandatory-by-mobile_API parameters missing, RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app
				--RELATE TO QUESTION: REVSDL-1130: per current API, "GetInteriorVehicleDataCapabilities" should not be tested against "omitted mandatory parameters" requirement.

			--Begin Test case CommonRequestCheck.1.1
			--Description: GetInteriorVehicleDataCapabilities with level parameter missing
				function Test:GetInteriorVehicleDataCapabilities_levelMissing()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							rowspan = 1,
							col = 1,
							levelspan = 1
						},
						moduleTypes = {"RADIO", "CLIMATE"}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.2
			--Description: GetInteriorVehicleDataCapabilities with Colspan parameter missing
				function Test:GetInteriorVehicleDataCapabilities_ColspanMissing()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						zone =
						{
							row = 1,
							rowspan = 1,
							col = 1,
							levelspan = 1,
							level = 1
						},
						moduleTypes = {"RADIO", "CLIMATE"}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.3
			--Description: GetInteriorVehicleDataCapabilities with row parameter missing
				function Test:GetInteriorVehicleDataCapabilities_RowMissing()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						zone =
						{
							colspan = 1,
							rowspan = 1,
							col = 1,
							levelspan = 1,
							level = 1
						},
						moduleTypes = {"RADIO", "CLIMATE"}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.3

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.4
			--Description: GetInteriorVehicleDataCapabilities with rowspan parameter missing
				function Test:GetInteriorVehicleDataCapabilities_RowspanMissing()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							col = 1,
							levelspan = 1,
							level = 1
						},
						moduleTypes = {"RADIO", "CLIMATE"}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.4

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.5
			--Description: GetInteriorVehicleDataCapabilities with col parameter missing
				function Test:GetInteriorVehicleDataCapabilities_ColMissing()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							rowspan = 1,
							levelspan = 1,
							level = 1
						},
						moduleTypes = {"RADIO", "CLIMATE"}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.5

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.6
			--Description: GetInteriorVehicleDataCapabilities with levelspan parameter missing
				function Test:GetInteriorVehicleDataCapabilities_LevelspanMissing()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							rowspan = 1,
							col = 1,
							level = 1
						},
						moduleTypes = {"RADIO", "CLIMATE"}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.6

	--End Test case CommonRequestCheck.1

		-----------------------------------------------------------------------------------------

	--Begin Test case CommonRequestCheck.2
	--Description: 	--param has an out-of-bounds value
					--[REVSDL-932]: 3 Parameters out of bounds

		--Requirement/Diagrams id in jira:
				--REVSDL-932
				--REVSDL-938
				--https://adc.luxoft.com/jira/secure/attachment/115809/115809_Req_1_3_of_REVSDL-932.png

		--Verification criteria:
				--In case app sends RPC with one or more mandatory or non-mandatory by-mobile_API parameters out of bounds, RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app

			--Begin Test case CommonRequestCheck.2.1
			--Description: GetInteriorVehicleDataCapabilities with all parameters out of bounds
				function Test:GetInteriorVehicleDataCapabilities_AllParametersOutLowerBound()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						zone =
						{
							colspan = -1,
							row = -1,
							rowspan = -1,
							col = -1,
							levelspan = -1,
							level = -1
						},
						moduleTypes = {}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.2
			--Description: GetInteriorVehicleDataCapabilities with Colspan parameter out of bounds
				function Test:GetInteriorVehicleDataCapabilities_ColspanOutLowerBound()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						zone =
						{
							colspan = -1,
							row = 1,
							rowspan = 1,
							col = 1,
							levelspan = 1,
							level = 1
						},
						moduleTypes = {"RADIO", "CLIMATE"}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.3
			--Description: GetInteriorVehicleDataCapabilities with row parameter out of bounds
				function Test:GetInteriorVehicleDataCapabilities_RowOutLowerBound()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						zone =
						{
							colspan = 1,
							row = -1,
							rowspan = 1,
							col = 1,
							levelspan = 1,
							level = 1
						},
						moduleTypes = {"RADIO", "CLIMATE"}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.3

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.4
			--Description: GetInteriorVehicleDataCapabilities with rowspan parameter out of bounds
				function Test:GetInteriorVehicleDataCapabilities_RowspanOutLowerBound()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							rowspan = -1,
							col = 1,
							levelspan = 1,
							level = 1
						},
						moduleTypes = {"RADIO", "CLIMATE"}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.4

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.5
			--Description: GetInteriorVehicleDataCapabilities with col parameter out of bounds
				function Test:GetInteriorVehicleDataCapabilities_ColOutLowerBound()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							rowspan = 1,
							col = -1,
							levelspan = 1,
							level = 1
						},
						moduleTypes = {"RADIO"}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.5

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.6
			--Description: GetInteriorVehicleDataCapabilities with levelspan parameter out of bounds
				function Test:GetInteriorVehicleDataCapabilities_LevelspanOutLowerBound()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							rowspan = 1,
							col = 1,
							levelspan = -1,
							level = 1
						},
						moduleTypes = {"CLIMATE"}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.6

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.7
			--Description: GetInteriorVehicleDataCapabilities with level parameter out of bounds
				function Test:GetInteriorVehicleDataCapabilities_LevelOutLowerBound()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							rowspan = 1,
							col = 1,
							levelspan = 1,
							level = -1
						},
						moduleTypes = {"RADIO", "CLIMATE"}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.7

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.8
			--Description: GetInteriorVehicleDataCapabilities with moduleType parameters out of bounds. minisize = 1
				function Test:GetInteriorVehicleDataCapabilities_ModuleTypeOutLowerBound()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							rowspan = 1,
							col = 1,
							levelspan = 1,
							level = 1
						},
						moduleTypes = {}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.8

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.9
			--Description: GetInteriorVehicleDataCapabilities with all parameters out of bounds
				function Test:GetInteriorVehicleDataCapabilities_AllParametersOutUpperBound()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						zone =
						{
							colspan = 101,
							row = 101,
							rowspan = 101,
							col = 101,
							levelspan = 101,
							level = 101
						},
						moduleTypes = CreateModuleTypes("RADIO", 1001)
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.9

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.10
			--Description: GetInteriorVehicleDataCapabilities with Colspan parameter out of bounds
				function Test:GetInteriorVehicleDataCapabilities_ColspanOutUpperBound()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						zone =
						{
							colspan = 101,
							row = 1,
							rowspan = 1,
							col = 1,
							levelspan = 1,
							level = 1
						},
						moduleTypes = {"CLIMATE"}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.10

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.11
			--Description: GetInteriorVehicleDataCapabilities with row parameter out of bounds
				function Test:GetInteriorVehicleDataCapabilities_RowOutUpperBound()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						zone =
						{
							colspan = 1,
							row = 101,
							rowspan = 1,
							col = 1,
							levelspan = 1,
							level = 1
						},
						moduleTypes = {"RADIO", "CLIMATE"}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.11

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.12
			--Description: GetInteriorVehicleDataCapabilities with rowspan parameter out of bounds
				function Test:GetInteriorVehicleDataCapabilities_RowspanOutUpperBound()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							rowspan = 101,
							col = 1,
							levelspan = 1,
							level = 1
						},
						moduleTypes = {"RADIO", "CLIMATE"}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.12

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.13
			--Description: GetInteriorVehicleDataCapabilities with col parameter out of bounds
				function Test:GetInteriorVehicleDataCapabilities_ColOutUpperBound()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							rowspan = 1,
							col = 101,
							levelspan = 1,
							level = 1
						},
						moduleTypes = {"RADIO", "CLIMATE"}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.13

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.14
			--Description: GetInteriorVehicleDataCapabilities with levelspan parameter out of bounds
				function Test:GetInteriorVehicleDataCapabilities_LevelspanOutUpperBound()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							rowspan = 1,
							col = 1,
							levelspan = 101,
							level = 1
						},
						moduleTypes = {"RADIO", "CLIMATE"}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.14

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.15
			--Description: GetInteriorVehicleDataCapabilities with level parameter out of bounds
				function Test:GetInteriorVehicleDataCapabilities_LevelOutUpperBound()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							rowspan = 1,
							col = 1,
							levelspan = 1,
							level = 101
						},
						moduleTypes = {"RADIO", "CLIMATE"}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.15

			--Begin Test case CommonRequestCheck.2.16
			--Description: GetInteriorVehicleDataCapabilities with moduleType parameter out of bounds
				function Test:GetInteriorVehicleDataCapabilities_ModuleTypeOutUpperBound()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							rowspan = 1,
							col = 1,
							levelspan = 1,
							level = 1
						},
						moduleTypes = CreateModuleTypes("RADIO", 1001)
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.16

	--End Test case CommonRequestCheck.2

		-----------------------------------------------------------------------------------------

	--Begin Test case CommonRequestCheck.3
	--Description: 	--invalid json
					--[REVSDL-932]: 4. Wrong json

		--Requirement/Diagrams id in jira:
				--REVSDL-932
				--REVSDL-939
				--https://adc.luxoft.com/jira/secure/attachment/115813/115813_Req_1_4_REVSDL-932.png

		--Verification criteria:
				--In case app sends RPC in wrong JSON, RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app

			--Begin Test case CommonRequestCheck.3.1
			--Description: Request with invalid JSON syntax (INVALID_DATA)
				function Test:GetInteriorVehicleDataCapabilities_InvalidJson()
				  self.mobileSession.correlationId = self.mobileSession.correlationId + 1

				  local msg =
				  {
					serviceType      = 7,
					frameInfo        = 0,
					rpcType          = 0,
					rpcFunctionId    = 100016,
					rpcCorrelationId = self.mobileSession.correlationId,
					payload          = '{"zone":{"colspan":1,"row":1,"rowspan":1,"col":1,"levelspan":1,"level":1},"moduleType":{"CLIMATE" "RADIO"}}'
				  }
				  self.mobileSession:Send(msg)
				  self.mobileSession:ExpectResponse(self.mobileSession.correlationId, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.3.1

	--End Test case CommonRequestCheck.3

		-----------------------------------------------------------------------------------------

	--Begin Test case CommonRequestCheck.4
	--Description: 	--invalid json
					--[REVSDL-932]: 5. String with invalid characters

		--Requirement/Diagrams id in jira:
				--REVSDL-932
				--REVSDL-940
				--https://adc.luxoft.com/jira/secure/attachment/115818/115818_Req_1_5_of_REVSDL-932.png

		--Verification criteria:
				--In case app sends RPC with invalid characters in param of string type, RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app

		--SKIPPED because "Note: currently none of the listed RPCs has a string param." cloned to REVSDL-1005 [REVSDL-932]: 6. Parameter of wrong type

	--End Test case CommonRequestCheck.4

		-----------------------------------------------------------------------------------------

	--Begin Test case CommonRequestCheck.5
	--Description: 	--param of wrong type
					--[REVSDL-932]: 6. Parameter of wrong type

		--Requirement/Diagrams id in jira:
				--REVSDL-932
				--REVSDL-941
				--https://adc.luxoft.com/jira/secure/attachment/115819/115819_Req_1_6_of_REVSDL-932.png

		--Verification criteria:
				--In case app sends RPC with param of wrong type, RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app

			--Begin Test case CommonRequestCheck.5.1
			--Description: GetInteriorVehicleDataCapabilities with all parameters of wrong type
				function Test:GetInteriorVehicleDataCapabilities_AllParamsWrongType()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						zone =
						{
							colspan = "1",
							row = "1",
							rowspan = "1",
							col = "1",
							levelspan = "1",
							level = "1"
						},
						moduleTypes = {111, 111}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.2
			--Description: GetInteriorVehicleDataCapabilities with Colspan parameter of wrong type
				function Test:GetInteriorVehicleDataCapabilities_ColspanWrongType()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						zone =
						{
							colspan = "1",
							row = 1,
							rowspan = 1,
							col = 1,
							levelspan = 1,
							level = 1
						},
						moduleTypes = {"RADIO", "CLIMATE"}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.3
			--Description: GetInteriorVehicleDataCapabilities with row parameter of wrong type
				function Test:GetInteriorVehicleDataCapabilities_RowWrongType()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						zone =
						{
							colspan = 1,
							row = "1",
							rowspan = 1,
							col = 1,
							levelspan = 1,
							level = 1
						},
						moduleTypes = {"RADIO", "CLIMATE"}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.3

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.4
			--Description: GetInteriorVehicleDataCapabilities with rowspan parameter of wrong type
				function Test:GetInteriorVehicleDataCapabilities_RowspanWrongType()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							rowspan = "1",
							col = 1,
							levelspan = 1,
							level = 1
						},
						moduleTypes = {"RADIO", "CLIMATE"}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.4

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.5
			--Description: GetInteriorVehicleDataCapabilities with col parameter of wrong type
				function Test:GetInteriorVehicleDataCapabilities_ColWrongType()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							rowspan = 1,
							col = "1",
							levelspan = 1,
							level = 1
						},
						moduleTypes = {"RADIO", "CLIMATE"}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.5

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.6
			--Description: GetInteriorVehicleDataCapabilities with levelspan parameter of wrong type
				function Test:GetInteriorVehicleDataCapabilities_LevelspanWrongType()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							rowspan = 1,
							col = 1,
							levelspan = "1",
							level = 1
						},
						moduleTypes = {"RADIO", "CLIMATE"}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.6

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.7
			--Description: GetInteriorVehicleDataCapabilities with level parameter of wrong type
				function Test:GetInteriorVehicleDataCapabilities_levelWrongType()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							rowspan = 1,
							col = 1,
							levelspan = 1,
							level = "1"
						},
						moduleTypes = {"RADIO", "CLIMATE"}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.7

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.8
			--Description: GetInteriorVehicleDataCapabilities with moduleType parameter of wrong type
				function Test:GetInteriorVehicleDataCapabilities_ModuleTypeWrongType()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							rowspan = 1,
							col = 1,
							levelspan = 1,
							level = 1
						},
						moduleTypes = 111
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.8

		-----------------------------------------------------------------------------------------


			--Begin Test case CommonRequestCheck.5.9
			--Description: GetInteriorVehicleDataCapabilities with zone parameter of wrong type
				function Test:GetInteriorVehicleDataCapabilities_ZoneWrongType()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						zone =
						{
							colspan = "1",
							row = true,
							rowspan = false,
							col = 1,
							levelspan = "1",
							level = "abc"
						},
						moduleTypes = {"RADIO", "CLIMATE"}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.9

			--Begin Test case CommonRequestCheck.5.10
			--Description: GetInteriorVehicleDataCapabilities with rowspan and ModuleType parameters of wrong type
				function Test:GetInteriorVehicleDataCapabilities_RowspanAndModuleTypeWrongType()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							rowspan = "1",
							col = 1,
							levelspan = 1,
							level = 1
						},
						moduleTypes = {111, "abc"}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.10

			--Begin Test case CommonRequestCheck.5.11
			--Description: GetInteriorVehicleDataCapabilities with moduleType with elements parameter of wrong type
				function Test:GetInteriorVehicleDataCapabilities_ModuleTypeElementsWrongType()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						zone =
						{
							colspan = 1,
							row = 1,
							rowspan = 1,
							col = 1,
							levelspan = 1,
							level = 1
						},
						moduleTypes = {111}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.11

		-----------------------------------------------------------------------------------------

	--End Test case CommonRequestCheck.5

		-----------------------------------------------------------------------------------------

	--Begin Test case CommonRequestCheck.6
	--Description: 	--RSDL cuts off the fake param (non-existent per Mobile_API) from app's RPC.
					--[REVSDL-932]: 7. Fake params

		--Requirement/Diagrams id in jira:
				--REVSDL-932
				--REVSDL-997
				--https://adc.luxoft.com/jira/secure/attachment/116227/116227_Req_1_2_7_of_REVSDL-932.png

		--Verification criteria:
				--In case app sends RPC with fake param (non-existent per Mobile_API), RSDL must cut this param off from the RPC and then validate this RPC and process as assigned.

			--Begin Test case CommonRequestCheck.6.1
			--Description: app sends RPC with fake param inside zone
				function Test:GetInteriorVehicleDataCapabilities_FakeParamsInsideZone()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						zone =
						{
							fake1 = true,
							colspan = 2,
							row = 0,
							rowspan = 2,
							col = 0,
							fake2 = 1,
							levelspan = 1,
							level = 0
						},
						moduleTypes = {"RADIO"}
					})

				--hmi side: expect RC.GetInteriorVehicleDataCapabilities request
				EXPECT_HMICALL("RC.GetInteriorVehicleDataCapabilities",
								{
									zone =
									{
										colspan = 2,
										row = 0,
										rowspan = 2,
										col = 0,
										levelspan = 1,
										level = 0
									},
									moduleTypes = {"RADIO"}
								})
					:ValidIf (function(_,data)
										if data.params.zone.fake1 or data.params.zone.fake2 then
											print(" --SDL sends fake parameter to HMI ")
											for key,value in pairs(data.params.zone) do print(key,value) end
											return false
										else
											return true
										end
									end)
									:Timeout(2000)
				end
			--End Test case CommonRequestCheck.6.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.6.2
			--Description: app sends RPC with fake param outside zone
				function Test:GetInteriorVehicleDataCapabilities_FakeParamsOutsideZone()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						zone =
						{
							colspan = 2,
							row = 0,
							rowspan = 2,
							col = 0,
							levelspan = 1,
							level = 0
						},
						fake1 = "RADIO",
						moduleTypes = {"CLIMATE"},
						fake2 = false
					})

				--hmi side: expect RC.GetInteriorVehicleDataCapabilities request
				EXPECT_HMICALL("RC.GetInteriorVehicleDataCapabilities",
								{
									zone =
									{
										colspan = 2,
										row = 0,
										rowspan = 2,
										col = 0,
										levelspan = 1,
										level = 0
									},
									moduleTypes = {"CLIMATE"}
								})
					:ValidIf (function(_,data)
										if data.params.fake1 or data.params.fake2 then
											print(" --SDL sends fake parameter to HMI ")
											for key,value in pairs(data.params) do print(key,value) end
											return false
										else
											return true
										end
									end)
									:Timeout(2000)
				end
			--End Test case CommonRequestCheck.6.2
	--End Test case CommonRequestCheck.6

		-----------------------------------------------------------------------------------------

--=================================================END TEST CASES 2==========================================================--






--=================================================BEGIN TEST CASES 3==========================================================--
	--Begin Test suit CommonRequestCheck.3 for GetInteriorVehicleData

	--Description: Validation App's RPC for GetInteriorVehicleData request

	--Begin Test suit CommonRequestCheck

	--Description: TC's checks processing
		-- mandatory param is missing
		-- param has an out-of-bounds value
		-- invalid json
		-- string param with invalid characters
		-- param of wrong type


	--Begin Test case CommonRequestCheck.1
	--Description: 	--mandatory param is missing
					--[REVSDL-932]: 2. Mandatory params missing

		--Requirement/Diagrams id in jira:
				--REVSDL-932
				--REVSDL-937
				--https://adc.luxoft.com/jira/secure/attachment/115807/115807_Req_1_2_of_REVSDL-932.png

		--Verification criteria:
				--In case app sends RPC with one or more mandatory-by-mobile_API parameters missing, RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app

	--RELATE TO QUESTION: REVSDL-1130: per current API, "GetInteriorVehicleDataCapabilities" should not be tested against "omitted mandatory parameters" requirement.

			--Begin Test case CommonRequestCheck.1.1
			--Description: GetInteriorVehicleData with all parameters missing
				function Test:GetInteriorVehicleData_AllParamsMissing()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.2
			--Description: GetInteriorVehicleData with Colspan parameter missing
				function Test:GetInteriorVehicleData_ColspanMissing()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								row = 1,
								rowspan = 1,
								col = 1,
								levelspan = 1,
								level = 1
							}
						},
						subscribe = true
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.3
			--Description: GetInteriorVehicleData with row parameter missing
				function Test:GetInteriorVehicleData_RowMissing()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								clospan = 1,
								rowspan = 1,
								col = 1,
								levelspan = 1,
								level = 1
							}
						},
						subscribe = true
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.3

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.4
			--Description: GetInteriorVehicleData with rowspan parameter missing
				function Test:GetInteriorVehicleData_RowspanMissing()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								clospan = 1,
								row = 1,
								col = 1,
								levelspan = 1,
								level = 1
							}
						},
						subscribe = true
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.4

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.5
			--Description: GetInteriorVehicleData with col parameter missing
				function Test:GetInteriorVehicleData_ColMissing()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								clospan = 1,
								row = 1,
								rowspan = 1,
								levelspan = 1,
								level = 1
							}
						},
						subscribe = true
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.5

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.6
			--Description: GetInteriorVehicleData with levelspan parameter missing
				function Test:GetInteriorVehicleData_LevelspanMissing()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								clospan = 1,
								row = 1,
								rowspan = 1,
								col = 1,
								level = 1
							}
						},
						subscribe = true
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.6

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.7
			--Description: GetInteriorVehicleData with level parameter missing
				function Test:GetInteriorVehicleData_levelMissing()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								clospan = 1,
								row = 1,
								rowspan = 1,
								col = 1,
								levelspan = 1
							}
						},
						subscribe = true
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.7

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.8
			--Description: GetInteriorVehicleData with moduleType parameter missing
				function Test:GetInteriorVehicleData_ModuleTypeMissing()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleZone =
							{
								clospan = 1,
								row = 1,
								rowspan = 1,
								col = 1,
								levelspan = 1,
								level = 1
							}
						},
						subscribe = true
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.8

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.9
			--Description: GetInteriorVehicleData with moduleZone parameter missing
				function Test:GetInteriorVehicleData_ModuleZoneMissing()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "CLIMATE"
						},
						subscribe = true
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.9

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.10
			--Description: GetInteriorVehicleData with moduleDescription parameter missing
				function Test:GetInteriorVehicleData_ModuleDescriptionMissing()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						subscribe = true
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.10

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.11
			--Description: GetInteriorVehicleData with subscribe parameter missing
				function Test:GetInteriorVehicleData_SubscribeMissing()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}
					})

				--hmi side: expect RC.GetInteriorVehicleData request
				EXPECT_HMICALL("RC.GetInteriorVehicleData")
					:Do(function(_,data)
						--hmi side: sending RC.GetInteriorVehicleData response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { moduleData = {
													moduleType = "RADIO",
													moduleZone = {
														col = 0,
														colspan = 2,
														level = 0,
														levelspan = 1,
														row = 0,
														rowspan = 2
													},
													radioControlData = {
														frequencyInteger = 99,
														frequencyFraction = 3,
														band = "FM",
														rdsData = {
															PS = "name",
															RT = "radio",
															CT = "YYYY-MM-DDThh:mm:ss.sTZD",
															PI = "Sign",
															PTY = 1,
															TP = true,
															TA = true,
															REG = "Murica"
														},
														availableHDs = 3,
														hdChannel = 1,
														signalStrength = 50,
														signalChangeThreshold = 60,
														radioEnable = true,
														state = "ACQUIRING"
													}
												}
												})
					end)

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })

				end
			--End Test case CommonRequestCheck.1.11

	--End Test case CommonRequestCheck.1

		-----------------------------------------------------------------------------------------

	--Begin Test case CommonRequestCheck.2
	--Description: 	--param has an out-of-bounds value
					--[REVSDL-932]: 3 Parameters out of bounds

		--Requirement/Diagrams id in jira:
				--REVSDL-932
				--REVSDL-938
				--https://adc.luxoft.com/jira/secure/attachment/115809/115809_Req_1_3_of_REVSDL-932.png

		--Verification criteria:
				--In case app sends RPC with one or more mandatory or non-mandatory by-mobile_API parameters out of bounds, RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app

			--Begin Test case CommonRequestCheck.2.1
			--Description: GetInteriorVehicleData with all parameters out of bounds
				function Test:GetInteriorVehicleData_AllParametersOutLowerBound()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								clospan = -1,
								row = -1,
								rowspan = -1,
								col = -1,
								levelspan = -1,
								level = -1
							}
						},
						subscribe = true
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.2
			--Description: GetInteriorVehicleData with Colspan parameter out of bounds
				function Test:GetInteriorVehicleData_ColspanOutLowerBound()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								clospan = -1,
								row = 1,
								rowspan = 1,
								col = 1,
								levelspan = 1,
								level = 1
							}
						},
						subscribe = true
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.3
			--Description: GetInteriorVehicleData with row parameter out of bounds
				function Test:GetInteriorVehicleData_RowOutLowerBound()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								clospan = 1,
								row = -1,
								rowspan = 1,
								col = 1,
								levelspan = 1,
								level = 1
							}
						},
						subscribe = true
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.3

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.4
			--Description: GetInteriorVehicleData with rowspan parameter out of bounds
				function Test:GetInteriorVehicleData_RowspanOutLowerBound()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								clospan = 1,
								row = 1,
								rowspan = -1,
								col = 1,
								levelspan = 1,
								level = 1
							}
						},
						subscribe = true
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.4

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.5
			--Description: GetInteriorVehicleData with col parameter out of bounds
				function Test:GetInteriorVehicleData_ColOutLowerBound()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								clospan = 1,
								row = 1,
								rowspan = 1,
								col = -1,
								levelspan = 1,
								level = 1
							}
						},
						subscribe = true
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.5

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.6
			--Description: GetInteriorVehicleData with levelspan parameter out of bounds
				function Test:GetInteriorVehicleData_LevelspanOutLowerBound()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								clospan = 1,
								row = 1,
								rowspan = 1,
								col = 1,
								levelspan = -1,
								level = 1
							}
						},
						subscribe = true
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.6

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.7
			--Description: GetInteriorVehicleData with level parameter out of bounds
				function Test:GetInteriorVehicleData_LevelOutLowerBound()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								clospan = 1,
								row = 1,
								rowspan = 1,
								col = 1,
								levelspan = 1,
								level = -1
							}
						},
						subscribe = true
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.7

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.8
			--Description: GetInteriorVehicleData with all parameters out of bounds
				function Test:GetInteriorVehicleData_AllParametersOutUpperBound()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								clospan = 101,
								row = 101,
								rowspan = 101,
								col = 101,
								levelspan = 101,
								level = 101
							}
						},
						subscribe = true
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.8

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.9
			--Description: GetInteriorVehicleData with Colspan parameter out of bounds
				function Test:GetInteriorVehicleData_ColspanOutUpperBound()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								clospan = 101,
								row = 1,
								rowspan = 1,
								col = 1,
								levelspan = 1,
								level = 1
							}
						},
						subscribe = true
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.9

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.10
			--Description: GetInteriorVehicleData with row parameter out of bounds
				function Test:GetInteriorVehicleData_RowOutUpperBound()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								clospan = 1,
								row = 101,
								rowspan = 1,
								col = 1,
								levelspan = 1,
								level = 1
							}
						},
						subscribe = true
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.10

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.11
			--Description: GetInteriorVehicleData with rowspan parameter out of bounds
				function Test:GetInteriorVehicleData_RowspanOutUpperBound()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								clospan = 1,
								row = 1,
								rowspan = 101,
								col = 1,
								levelspan = 1,
								level = 1
							}
						},
						subscribe = true
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.11

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.12
			--Description: GetInteriorVehicleData with col parameter out of bounds
				function Test:GetInteriorVehicleData_ColOutUpperBound()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								clospan = 1,
								row = 1,
								rowspan = 1,
								col = 101,
								levelspan = 1,
								level = 1
							}
						},
						subscribe = true
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.12

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.13
			--Description: GetInteriorVehicleData with levelspan parameter out of bounds
				function Test:GetInteriorVehicleData_LevelspanOutUpperBound()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								clospan = 1,
								row = 1,
								rowspan = 1,
								col = 1,
								levelspan = 101,
								level = 1
							}
						},
						subscribe = true
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.13

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.14
			--Description: GetInteriorVehicleData with level parameter out of bounds
				function Test:GetInteriorVehicleData_LevelOutUpperBound()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								clospan = 1,
								row = 1,
								rowspan = 1,
								col = 1,
								levelspan = 1,
								level = 101
							}
						},
						subscribe = true
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.14

	--End Test case CommonRequestCheck.2

		-----------------------------------------------------------------------------------------

	--Begin Test case CommonRequestCheck.3
	--Description: 	--invalid json
					--[REVSDL-932]: 4. Wrong json

		--Requirement/Diagrams id in jira:
				--REVSDL-932
				--REVSDL-939
				--https://adc.luxoft.com/jira/secure/attachment/115813/115813_Req_1_4_REVSDL-932.png

		--Verification criteria:
				--In case app sends RPC in wrong JSON, RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app

			--Begin Test case CommonRequestCheck.3.1
			--Description: Request with invalid JSON syntax (INVALID_DATA)
				function Test:GetInteriorVehicleData_InvalidJson()
				  self.mobileSession.correlationId = self.mobileSession.correlationId + 1

				  local msg =
				  {
					serviceType      = 7,
					frameInfo        = 0,
					rpcType          = 0,
					rpcFunctionId    = 100017,
					rpcCorrelationId = self.mobileSession.correlationId,
					payload          = '{"moduleDescription":{"moduleType":"CLIMATE","moduleZone":{"col":1,"colspan":1,"level":1,"levelspan":1,"row":1,"rowspan":1}},"subscribe" false}'
				  }
				  self.mobileSession:Send(msg)
				  self.mobileSession:ExpectResponse(self.mobileSession.correlationId, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.3.1

	--End Test case CommonRequestCheck.3

		-----------------------------------------------------------------------------------------

	--Begin Test case CommonRequestCheck.4
	--Description: 	--invalid json
					--[REVSDL-932]: 5. String with invalid characters

		--Requirement/Diagrams id in jira:
				--REVSDL-932
				--REVSDL-940
				--https://adc.luxoft.com/jira/secure/attachment/115818/115818_Req_1_5_of_REVSDL-932.png

		--Verification criteria:
				--In case app sends RPC with invalid characters in param of string type, RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app

		--SKIPPED because "Note: currently none of the listed RPCs has a string param." cloned to REVSDL-1005 [REVSDL-932]: 6. Parameter of wrong type

	--End Test case CommonRequestCheck.4

		-----------------------------------------------------------------------------------------

	--Begin Test case CommonRequestCheck.5
	--Description: 	--param of wrong type
					--[REVSDL-932]: 6. Parameter of wrong type

		--Requirement/Diagrams id in jira:
				--REVSDL-932
				--REVSDL-941
				--https://adc.luxoft.com/jira/secure/attachment/115819/115819_Req_1_6_of_REVSDL-932.png

		--Verification criteria:
				--In case app sends RPC with param of wrong type, RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app

			--Begin Test case CommonRequestCheck.5.1
			--Description: GetInteriorVehicleData with all parameters of wrong type
				function Test:GetInteriorVehicleData_AllParamsWrongType()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = 1234567,
							moduleZone =
							{
								clospan = "1",
								row = "1",
								rowspan = "1",
								col = "1",
								levelspan = "1",
								level = "1"
							}
						},
						subscribe = "true"
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.2
			--Description: GetInteriorVehicleData with Colspan parameter of wrong type
				function Test:GetInteriorVehicleData_ColspanWrongType()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								clospan = "1",
								row = 1,
								rowspan = 1,
								col = 1,
								levelspan = 1,
								level = 1
							}
						},
						subscribe = true
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.3
			--Description: GetInteriorVehicleData with row parameter of wrong type
				function Test:GetInteriorVehicleData_RowWrongType()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								clospan = 1,
								row = true,
								rowspan = 1,
								col = 1,
								levelspan = 1,
								level = 1
							}
						},
						subscribe = true
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.3

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.4
			--Description: GetInteriorVehicleData with rowspan parameter of wrong type
				function Test:GetInteriorVehicleData_RowspanWrongType()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								clospan = 1,
								row = 1,
								rowspan = "1",
								col = 1,
								levelspan = 1,
								level = 1
							}
						},
						subscribe = true
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.4

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.5
			--Description: GetInteriorVehicleData with col parameter of wrong type
				function Test:GetInteriorVehicleData_ColWrongType()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								clospan = 1,
								row = 1,
								rowspan = 1,
								col = "1",
								levelspan = 1,
								level = 1
							}
						},
						subscribe = true
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.5

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.6
			--Description: GetInteriorVehicleData with levelspan parameter of wrong type
				function Test:GetInteriorVehicleData_LevelspanWrongType()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								clospan = 1,
								row = 1,
								rowspan = 1,
								col = 1,
								levelspan = "1",
								level = 1
							}
						},
						subscribe = true
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.6

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.7
			--Description: GetInteriorVehicleData with level parameter of wrong type
				function Test:GetInteriorVehicleData_levelWrongType()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								clospan = 1,
								row = 1,
								rowspan = 1,
								col = 1,
								levelspan = 1,
								level = "1"
							}
						},
						subscribe = true
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.7

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.8
			--Description: GetInteriorVehicleData with moduleType parameter of wrong type
				function Test:GetInteriorVehicleData_ModuleTypeWrongType()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = true,
							moduleZone =
							{
								clospan = 1,
								row = 1,
								rowspan = 1,
								col = 1,
								levelspan = 1,
								level = 1
							}
						},
						subscribe = true
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.8

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.9
			--Description: GetInteriorVehicleData with subscribe parameter of wrong type
				function Test:GetInteriorVehicleData_SubscribeModeWrongType()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								clospan = 1,
								row = 1,
								rowspan = 1,
								col = 1,
								levelspan = 1,
								level = 1
							}
						},
						subscribe = "true"
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.9

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.10
			--Description: GetInteriorVehicleData with ModuleZone parameter of wrong type
				function Test:GetInteriorVehicleData_ModuleZoneWrongType()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "CLIMATE",
							moduleZone = "abc"
						},
						subscribe = true
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.10

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.11
			--Description: GetInteriorVehicleData with ModuleDescription parameter of wrong type
				function Test:GetInteriorVehicleData_ModuleDescriptionWrongType()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription = "abc",
						subscribe = true
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.11

	--End Test case CommonRequestCheck.5

		-----------------------------------------------------------------------------------------

	--Begin Test case CommonRequestCheck.6
	--Description: 	--RSDL cuts off the fake param (non-existent per Mobile_API) from app's RPC.
					--[REVSDL-932]: 7. Fake params

		--Requirement/Diagrams id in jira:
				--REVSDL-932
				--REVSDL-997
				--https://adc.luxoft.com/jira/secure/attachment/116227/116227_Req_1_2_7_of_REVSDL-932.png

		--Verification criteria:
				--In case app sends RPC with fake param (non-existent per Mobile_API), RSDL must cut this param off from the RPC and then validate this RPC and process as assigned.

			--Begin Test case CommonRequestCheck.6.1
			--Description: app sends RPC with fake param inside moduleZone
				function Test:GetInteriorVehicleData_FakeParamsInsideModuleZone()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "RADIO",
							moduleZone =
							{
								fake1 = 1,
								colspan = 2,
								row = 0,
								rowspan = 2,
								fake2 = true,
								col = 0,
								levelspan = 1,
								level = 0,
								fake3 = "abc  xyz  "
							}
						},
						subscribe = true
					})

				--hmi side: expect RC.GetInteriorVehicleData request
				EXPECT_HMICALL("RC.GetInteriorVehicleData")
				:ValidIf (function(_,data)
						if data.params.moduleDescription.moduleZone.fake1 then
							print(" --SDL sends fake parameter to HMI ")
							for key,value in pairs(data.params) do print(key,value) end
							return false
						else
							return true
						end
					end)
					:Timeout(3000)

				end
			--End Test case CommonRequestCheck.6.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.6.2
			--Description: app sends RPC with fake param outside moduleZone
				function Test:GetInteriorVehicleData_FakeParamsOutsideModuleZone()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							fake1 = 123,
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							fake2 = true
						},
						fake3 = "  abc  xyz   ",
						subscribe = true
					})

				--hmi side: expect RC.GetInteriorVehicleData request
				EXPECT_HMICALL("RC.GetInteriorVehicleData")
				:ValidIf (function(_,data)
						if data.params.moduleDescription.fake1 then
							print(" --SDL sends fake parameter to HMI ")
							for key,value in pairs(data.params) do print(key,value) end
							return false
						else
							return true
						end
					end)
					:Timeout(3000)
				end
			--End Test case CommonRequestCheck.6.2

	--End Test case CommonRequestCheck.6

		-----------------------------------------------------------------------------------------

--=================================================END TEST CASES 3==========================================================--








--=================================================BEGIN TEST CASES 4==========================================================--
	--Begin Test suit CommonRequestCheck.4 for SetInteriorVehicleData

	--Description: Validation App's RPC for SetInteriorVehicleData request

	--Begin Test suit CommonRequestCheck

	--Description: TC's checks processing
		-- mandatory param is missing
		-- param has an out-of-bounds value
		-- invalid json
		-- string param with invalid characters
		-- param of wrong type


	--Begin Test case CommonRequestCheck.1
	--Description: 	--mandatory param is missing
					--[REVSDL-932]: 2. Mandatory params missing

		--Requirement/Diagrams id in jira:
				--REVSDL-932
				--REVSDL-937
				--https://adc.luxoft.com/jira/secure/attachment/115807/115807_Req_1_2_of_REVSDL-932.png

		--Verification criteria:
				--In case app sends RPC with one or more mandatory-by-mobile_API parameters missing, RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app

			--Begin Test case CommonRequestCheck.1.1
			--Description: SetInteriorVehicleData with all parameters missing
				function Test:SetInteriorVehicleData_AllParamsMissing()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.2
			--Description: SetInteriorVehicleData with Colspan parameter missing
				function Test:SetInteriorVehicleData_ColspanMissing()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.3
			--Description: SetInteriorVehicleData with row parameter missing
				function Test:SetInteriorVehicleData_RowMissing()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.3

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.4
			--Description: SetInteriorVehicleData with rowspan parameter missing
				function Test:SetInteriorVehicleData_RowspanMissing()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.4

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.5
			--Description: SetInteriorVehicleData with col parameter missing
				function Test:SetInteriorVehicleData_ColMissing()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								levelspan = 1,
								level = 0
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.5

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.6
			--Description: SetInteriorVehicleData with levelspan parameter missing
				function Test:SetInteriorVehicleData_LevelspanMissing()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								level = 0
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.6

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.7
			--Description: SetInteriorVehicleData with level parameter missing
				function Test:SetInteriorVehicleData_levelMissing()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.7

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.8
			--Description: SetInteriorVehicleData with moduleType parameter missing for RADIO request
				function Test:SetInteriorVehicleData_RADIO_ModuleTypeMissing()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.8

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.9
			--Description: SetInteriorVehicleData with moduleType parameter missing for CLIMATE request
				function Test:SetInteriorVehicleData_CLIMATE_ModuleTypeMissing()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								circulateAirEnable = true,
								dualModeEnable = true,
								currentTemp = 30,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.9

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.10
			--Description: SetInteriorVehicleData with moduleType parameter missing for both RADIO and CLIMATE
				function Test:SetInteriorVehicleData_BOTH_ModuleTypeMissing()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleZone =
							{
								clospan = 1,
								row = 1,
								rowspan = 1,
								col = 1,
								levelspan = 1,
								level = 1
							},
							climateControlData =
							{
								fanSpeed = 30,
								circulateAirEnable = false,
								dualModeEnable = true,
								currentTemp = 21,
								defrostZone = "All",
								acEnable = true,
								desiredTemp = 20,
								autoModeEnable = false
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.10

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.11
			--Description: SetInteriorVehicleData with radioControlData parameter missing
				function Test:SetInteriorVehicleData_RadioControlDataMissing()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "RADIO",
							moduleZone =
							{
								clospan = 1,
								row = 1,
								rowspan = 1,
								col = 1,
								levelspan = 1,
								level = 1
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.11

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.12
			--Description: SetInteriorVehicleData with radioEnable parameter missing
				function Test:SetInteriorVehicleData_RadioEnableMissing()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}
					})

				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
						--hmi side: sending RC.SetInteriorVehicleData response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														moduleData =
														{
															radioControlData =
															{
																frequencyInteger = 105,
																frequencyFraction = 3,
																band = "AM",
																hdChannel = 1,
																state = "ACQUIRED",
																availableHDs = 1,
																signalStrength = 50,
																rdsData =
																{
																	PS = "12345678",
																	RT = "",
																	CT = "123456789012345678901234",
																	PI = "",
																	PTY = 0,
																	TP = true,
																	TA = false,
																	REG = ""
																},
																signalChangeThreshold = 10
															},
															moduleType = "RADIO",
															moduleZone =
															{
																colspan = 2,
																row = 0,
																rowspan = 2,
																col = 0,
																levelspan = 1,
																level = 0
															}
														}
						})
					end)

				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.1.12

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.13
			--Description: SetInteriorVehicleData with frequencyInteger parameter missing
				function Test:SetInteriorVehicleData_FrequencyIntegerMissing()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}
					})

				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
						--hmi side: sending RC.SetInteriorVehicleData response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														moduleData =
														{
															radioControlData =
															{
																radioEnable = true,
																frequencyFraction = 3,
																band = "AM",
																hdChannel = 1,
																state = "ACQUIRED",
																availableHDs = 1,
																signalStrength = 50,
																rdsData =
																{
																	PS = "12345678",
																	RT = "",
																	CT = "123456789012345678901234",
																	PI = "",
																	PTY = 0,
																	TP = true,
																	TA = false,
																	REG = ""
																},
																signalChangeThreshold = 10
															},
															moduleType = "RADIO",
															moduleZone =
															{
																colspan = 2,
																row = 0,
																rowspan = 2,
																col = 0,
																levelspan = 1,
																level = 0
															}
														}
						})
					end)

				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.1.13

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.14
			--Description: SetInteriorVehicleData with frequencyFraction parameter missing
				function Test:SetInteriorVehicleData_FrequencyFractionMissing()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}
					})

				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
						--hmi side: sending RC.SetInteriorVehicleData response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														moduleData =
														{
															radioControlData =
															{
																radioEnable = true,
																frequencyInteger = 105,
																band = "AM",
																hdChannel = 1,
																state = "ACQUIRED",
																availableHDs = 1,
																signalStrength = 50,
																rdsData =
																{
																	PS = "12345678",
																	RT = "",
																	CT = "123456789012345678901234",
																	PI = "",
																	PTY = 0,
																	TP = true,
																	TA = false,
																	REG = ""
																},
																signalChangeThreshold = 10
															},
															moduleType = "RADIO",
															moduleZone =
															{
																colspan = 2,
																row = 0,
																rowspan = 2,
																col = 0,
																levelspan = 1,
																level = 0
															}
														}
						})
					end)

				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.1.14

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.15
			--Description: SetInteriorVehicleData with band parameter missing
				function Test:SetInteriorVehicleData_BandMissing()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}
					})

				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
						--hmi side: sending RC.SetInteriorVehicleData response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														moduleData =
														{
															radioControlData =
															{
																radioEnable = true,
																frequencyInteger = 105,
																frequencyFraction = 3,
																hdChannel = 1,
																state = "ACQUIRED",
																availableHDs = 1,
																signalStrength = 50,
																rdsData =
																{
																	PS = "12345678",
																	RT = "",
																	CT = "123456789012345678901234",
																	PI = "",
																	PTY = 0,
																	TP = true,
																	TA = false,
																	REG = ""
																},
																signalChangeThreshold = 10
															},
															moduleType = "RADIO",
															moduleZone =
															{
																colspan = 2,
																row = 0,
																rowspan = 2,
																col = 0,
																levelspan = 1,
																level = 0
															}
														}
						})
					end)

				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.1.15

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.16
			--Description: SetInteriorVehicleData with hdChannel parameter missing
				function Test:SetInteriorVehicleData_HdChannelMissing()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}
					})

				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
						--hmi side: sending RC.SetInteriorVehicleData response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														moduleData =
														{
															radioControlData =
															{
																radioEnable = true,
																frequencyInteger = 105,
																frequencyFraction = 3,
																band = "AM",
																state = "ACQUIRED",
																availableHDs = 1,
																signalStrength = 50,
																rdsData =
																{
																	PS = "12345678",
																	RT = "",
																	CT = "123456789012345678901234",
																	PI = "",
																	PTY = 0,
																	TP = true,
																	TA = false,
																	REG = ""
																},
																signalChangeThreshold = 10
															},
															moduleType = "RADIO",
															moduleZone =
															{
																colspan = 2,
																row = 0,
																rowspan = 2,
																col = 0,
																levelspan = 1,
																level = 0
															}
														}
						})
					end)

				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.1.16

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.17
			--Description: SetInteriorVehicleData with state parameter missing
				function Test:SetInteriorVehicleData_StateMissing()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}
					})

				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
						--hmi side: sending RC.SetInteriorVehicleData response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														moduleData =
														{
															radioControlData =
															{
																radioEnable = true,
																frequencyInteger = 105,
																frequencyFraction = 3,
																band = "AM",
																hdChannel = 1,
																availableHDs = 1,
																signalStrength = 50,
																rdsData =
																{
																	PS = "12345678",
																	RT = "",
																	CT = "123456789012345678901234",
																	PI = "",
																	PTY = 0,
																	TP = true,
																	TA = false,
																	REG = ""
																},
																signalChangeThreshold = 10
															},
															moduleType = "RADIO",
															moduleZone =
															{
																colspan = 2,
																row = 0,
																rowspan = 2,
																col = 0,
																levelspan = 1,
																level = 0
															}
														}
						})
					end)

				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.1.17

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.18
			--Description: SetInteriorVehicleData with availableHDs parameter missing
				function Test:SetInteriorVehicleData_AvailableHDsMissing()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}
					})

				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
						--hmi side: sending RC.SetInteriorVehicleData response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														moduleData =
														{
															radioControlData =
															{
																radioEnable = true,
																frequencyInteger = 105,
																frequencyFraction = 3,
																band = "AM",
																hdChannel = 1,
																state = "ACQUIRED",
																signalStrength = 50,
																rdsData =
																{
																	PS = "12345678",
																	RT = "",
																	CT = "123456789012345678901234",
																	PI = "",
																	PTY = 0,
																	TP = true,
																	TA = false,
																	REG = ""
																},
																signalChangeThreshold = 10
															},
															moduleType = "RADIO",
															moduleZone =
															{
																colspan = 2,
																row = 0,
																rowspan = 2,
																col = 0,
																levelspan = 1,
																level = 0
															}
														}
						})
					end)

				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.1.18

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.19
			--Description: SetInteriorVehicleData with signalStrength parameter missing
				function Test:SetInteriorVehicleData_SignalStrengthMissing()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}
					})

				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
						--hmi side: sending RC.SetInteriorVehicleData response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														moduleData =
														{
															radioControlData =
															{
																radioEnable = true,
																frequencyInteger = 105,
																frequencyFraction = 3,
																band = "AM",
																hdChannel = 1,
																state = "ACQUIRED",
																availableHDs = 1,
																rdsData =
																{
																	PS = "12345678",
																	RT = "",
																	CT = "123456789012345678901234",
																	PI = "",
																	PTY = 0,
																	TP = true,
																	TA = false,
																	REG = ""
																},
																signalChangeThreshold = 10
															},
															moduleType = "RADIO",
															moduleZone =
															{
																colspan = 2,
																row = 0,
																rowspan = 2,
																col = 0,
																levelspan = 1,
																level = 0
															}
														}
						})
					end)

				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.1.19

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.20
			--Description: SetInteriorVehicleData with rdsData parameter missing
				function Test:SetInteriorVehicleData_RdsDataMissing()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}
					})

				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
						--hmi side: sending RC.SetInteriorVehicleData response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														moduleData =
														{
															radioControlData =
															{
																radioEnable = true,
																frequencyInteger = 105,
																frequencyFraction = 3,
																band = "AM",
																hdChannel = 1,
																state = "ACQUIRED",
																availableHDs = 1,
																signalStrength = 50,
																signalChangeThreshold = 10
															},
															moduleType = "RADIO",
															moduleZone =
															{
																colspan = 2,
																row = 0,
																rowspan = 2,
																col = 0,
																levelspan = 1,
																level = 0
															}
														}
						})
					end)

				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.1.20

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.21
			--Description: SetInteriorVehicleData with PS parameter missing
				function Test:SetInteriorVehicleData_PSMissing()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.21

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.22
			--Description: SetInteriorVehicleData with RT parameter missing
				function Test:SetInteriorVehicleData_RTMissing()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.22

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.23
			--Description: SetInteriorVehicleData with CT parameter missing
				function Test:SetInteriorVehicleData_CTMissing()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.23

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.24
			--Description: SetInteriorVehicleData with PI parameter missing
				function Test:SetInteriorVehicleData_PIMissing()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.24

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.25
			--Description: SetInteriorVehicleData with PTY parameter missing
				function Test:SetInteriorVehicleData_PTYMissing()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.25

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.26
			--Description: SetInteriorVehicleData with TP parameter missing
				function Test:SetInteriorVehicleData_TPMissing()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.26

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.27
			--Description: SetInteriorVehicleData with TA parameter missing
				function Test:SetInteriorVehicleData_TAMissing()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.27

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.28
			--Description: SetInteriorVehicleData with REG parameter missing
				function Test:SetInteriorVehicleData_REGMissing()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.28

		-----------------------------------------------------------------------------------------


			--Begin Test case CommonRequestCheck.1.29
			--Description: SetInteriorVehicleData with signalChangeThreshold parameter missing
				function Test:SetInteriorVehicleData_SignalChangeThresholdMissing()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								}
							},
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}
					})

				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
						--hmi side: sending RC.SetInteriorVehicleData response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														moduleData =
														{
															radioControlData =
															{
																radioEnable = true,
																frequencyInteger = 105,
																frequencyFraction = 3,
																band = "AM",
																hdChannel = 1,
																state = "ACQUIRED",
																availableHDs = 1,
																signalStrength = 50,
																rdsData =
																{
																	PS = "12345678",
																	RT = "",
																	CT = "123456789012345678901234",
																	PI = "",
																	PTY = 0,
																	TP = true,
																	TA = false,
																	REG = ""
																}
															},
															moduleType = "RADIO",
															moduleZone =
															{
																colspan = 2,
																row = 0,
																rowspan = 2,
																col = 0,
																levelspan = 1,
																level = 0
															}
														}
						})
					end)

				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.1.29

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.30
			--Description: SetInteriorVehicleData with moduleZone parameter missing
				function Test:SetInteriorVehicleData_ModuleZoneMissing()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO"
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.30

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.31
			--Description: SetInteriorVehicleData with climateControlData parameter missing (INVALID_DATA)
				function Test:SetInteriorVehicleData_ClimateControlDataMissing()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}
					})

				--mobile side: expect INVALID_DATA response
				EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA"})
				end
			--End Test case CommonRequestCheck.1.31

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.32
			--Description: SetInteriorVehicleData with fanSpeed parameter missing
				function Test:SetInteriorVehicleData_FanSpeedMissing()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								circulateAirEnable = true,
								dualModeEnable = true,
								currentTemp = 30,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
					})

				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
						--hmi side: sending RC.SetInteriorVehicleData response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														moduleData =
														{
															moduleType = "CLIMATE",
															moduleZone =
															{
																colspan = 2,
																row = 0,
																rowspan = 2,
																col = 0,
																levelspan = 1,
																level = 0
															},
															climateControlData =
															{
																circulateAirEnable = true,
																dualModeEnable = true,
																currentTemp = 30,
																defrostZone = "FRONT",
																acEnable = true,
																desiredTemp = 24,
																autoModeEnable = true,
																temperatureUnit = "CELSIUS"
															}
														}
						})
					end)

				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.1.32

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.33
			--Description: SetInteriorVehicleData with circulateAirEnable parameter missing
				function Test:SetInteriorVehicleData_CirculateAirEnableMissing()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								dualModeEnable = true,
								currentTemp = 30,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
					})

				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
						--hmi side: sending RC.SetInteriorVehicleData response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														moduleData =
														{
															moduleType = "CLIMATE",
															moduleZone =
															{
																colspan = 2,
																row = 0,
																rowspan = 2,
																col = 0,
																levelspan = 1,
																level = 0
															},
															climateControlData =
															{
																fanSpeed = 50,
																dualModeEnable = true,
																currentTemp = 30,
																defrostZone = "FRONT",
																acEnable = true,
																desiredTemp = 24,
																autoModeEnable = true,
																temperatureUnit = "CELSIUS"
															}
														}
						})
					end)

				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.1.33

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.34
			--Description: SetInteriorVehicleData with dualModeEnable parameter missing
				function Test:SetInteriorVehicleData_DualModeEnableMissing()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								circulateAirEnable = true,
								currentTemp = 30,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
					})

				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
						--hmi side: sending RC.SetInteriorVehicleData response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														moduleData =
														{
															moduleType = "CLIMATE",
															moduleZone =
															{
																colspan = 2,
																row = 0,
																rowspan = 2,
																col = 0,
																levelspan = 1,
																level = 0
															},
															climateControlData =
															{
																fanSpeed = 50,
																circulateAirEnable = true,
																currentTemp = 30,
																defrostZone = "FRONT",
																acEnable = true,
																desiredTemp = 24,
																autoModeEnable = true,
																temperatureUnit = "CELSIUS"
															}
														}
						})
					end)

				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.1.34

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.35
			--Description: SetInteriorVehicleData with currentTemp parameter missing
				function Test:SetInteriorVehicleData_currentTempMissing()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								circulateAirEnable = true,
								dualModeEnable = true,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
					})

				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
						--hmi side: sending RC.SetInteriorVehicleData response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														moduleData =
														{
															moduleType = "CLIMATE",
															moduleZone =
															{
																colspan = 2,
																row = 0,
																rowspan = 2,
																col = 0,
																levelspan = 1,
																level = 0
															},
															climateControlData =
															{
																fanSpeed = 50,
																circulateAirEnable = true,
																dualModeEnable = true,
																defrostZone = "FRONT",
																acEnable = true,
																desiredTemp = 24,
																autoModeEnable = true,
																temperatureUnit = "CELSIUS"
															}
														}
						})
					end)

				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.1.35

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.36
			--Description: SetInteriorVehicleData with defrostZone parameter missing
				function Test:SetInteriorVehicleData_DefrostZoneMissing()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								circulateAirEnable = true,
								dualModeEnable = true,
								currentTemp = 30,
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
					})

				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
						--hmi side: sending RC.SetInteriorVehicleData response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														moduleData =
														{
															moduleType = "CLIMATE",
															moduleZone =
															{
																colspan = 2,
																row = 0,
																rowspan = 2,
																col = 0,
																levelspan = 1,
																level = 0
															},
															climateControlData =
															{
																fanSpeed = 50,
																circulateAirEnable = true,
																dualModeEnable = true,
																currentTemp = 30,
																acEnable = true,
																desiredTemp = 24,
																autoModeEnable = true,
																temperatureUnit = "CELSIUS"
															}
														}
						})
					end)

				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.1.36

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.37
			--Description: SetInteriorVehicleData with acEnable parameter missing
				function Test:SetInteriorVehicleData_AcEnableMissing()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								circulateAirEnable = true,
								dualModeEnable = true,
								currentTemp = 30,
								defrostZone = "FRONT",
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
					})

				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
						--hmi side: sending RC.SetInteriorVehicleData response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														moduleData =
														{
															moduleType = "CLIMATE",
															moduleZone =
															{
																colspan = 2,
																row = 0,
																rowspan = 2,
																col = 0,
																levelspan = 1,
																level = 0
															},
															climateControlData =
															{
																fanSpeed = 50,
																circulateAirEnable = true,
																dualModeEnable = true,
																currentTemp = 30,
																defrostZone = "FRONT",
																desiredTemp = 24,
																autoModeEnable = true,
																temperatureUnit = "CELSIUS"
															}
														}
						})
					end)

				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.1.37

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.38
			--Description: SetInteriorVehicleData with desiredTemp parameter missing
				function Test:SetInteriorVehicleData_DesiredTempMissing()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								circulateAirEnable = true,
								dualModeEnable = true,
								currentTemp = 30,
								defrostZone = "FRONT",
								acEnable = true,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
					})

				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
						--hmi side: sending RC.SetInteriorVehicleData response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														moduleData =
														{
															moduleType = "CLIMATE",
															moduleZone =
															{
																colspan = 2,
																row = 0,
																rowspan = 2,
																col = 0,
																levelspan = 1,
																level = 0
															},
															climateControlData =
															{
																fanSpeed = 50,
																circulateAirEnable = true,
																dualModeEnable = true,
																currentTemp = 30,
																defrostZone = "FRONT",
																acEnable = true,
																autoModeEnable = true,
																temperatureUnit = "CELSIUS"
															}
														}
						})
					end)

				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.1.38

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.39
			--Description: SetInteriorVehicleData with autoModeEnable parameter missing
				function Test:SetInteriorVehicleData_AutoModeEnableMissing()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								circulateAirEnable = true,
								dualModeEnable = true,
								currentTemp = 30,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 24,
								temperatureUnit = "CELSIUS"
							}
						}
					})

				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
						--hmi side: sending RC.SetInteriorVehicleData response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														moduleData =
														{
															moduleType = "CLIMATE",
															moduleZone =
															{
																colspan = 2,
																row = 0,
																rowspan = 2,
																col = 0,
																levelspan = 1,
																level = 0
															},
															climateControlData =
															{
																fanSpeed = 50,
																circulateAirEnable = true,
																dualModeEnable = true,
																currentTemp = 30,
																defrostZone = "FRONT",
																acEnable = true,
																desiredTemp = 24,
																temperatureUnit = "CELSIUS"
															}
														}
						})
					end)

				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.1.39

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.40
			--Description: SetInteriorVehicleData with TemperatureUnit parameter missing
				function Test:SetInteriorVehicleData_TemperatureUnitMissing()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								circulateAirEnable = true,
								dualModeEnable = true,
								currentTemp = 30,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true
							}
						}
					})

				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
						--hmi side: sending RC.SetInteriorVehicleData response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														moduleData =
														{
															moduleType = "CLIMATE",
															moduleZone =
															{
																colspan = 2,
																row = 0,
																rowspan = 2,
																col = 0,
																levelspan = 1,
																level = 0
															},
															climateControlData =
															{
																fanSpeed = 50,
																circulateAirEnable = true,
																dualModeEnable = true,
																currentTemp = 30,
																defrostZone = "FRONT",
																acEnable = true,
																desiredTemp = 24,
																autoModeEnable = true
															}
														}
						})
					end)

				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.1.40

	--End Test case CommonRequestCheck.1

		-----------------------------------------------------------------------------------------

	--Begin Test case CommonRequestCheck.2
	--Description: 	--param has an out-of-bounds value
					--[REVSDL-932]: 3 Parameters out of bounds

		--Requirement/Diagrams id in jira:
				--REVSDL-932
				--REVSDL-938
				--https://adc.luxoft.com/jira/secure/attachment/115809/115809_Req_1_3_of_REVSDL-932.png

		--Verification criteria:
				--In case app sends RPC with one or more mandatory or non-mandatory by-mobile_API parameters out of bounds, RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app

			--Begin Test case CommonRequestCheck.2.1
			--Description: SetInteriorVehicleData with all parameters out of bounds
				function Test:SetInteriorVehicleData_AllParamsOutLowerBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								colspan = -1,
								row = -1,
								rowspan = -1,
								col = -1,
								levelspan = -1,
								level = -1
							},
							climateControlData =
							{
								fanSpeed = -1,
								circulateAirEnable = true,
								dualModeEnable = true,
								currentTemp = -1,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = -1,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.2
			--Description: SetInteriorVehicleData with Colspan parameter out of bounds
				function Test:SetInteriorVehicleData_ColspanOutLowerBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								colspan = -1,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								circulateAirEnable = true,
								dualModeEnable = true,
								currentTemp = 30,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.3
			--Description: SetInteriorVehicleData with row parameter out of bounds
				function Test:SetInteriorVehicleData_RowOutLowerBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								colspan = 2,
								row = -1,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								circulateAirEnable = true,
								dualModeEnable = true,
								currentTemp = 30,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.3

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.4
			--Description: SetInteriorVehicleData with rowspan parameter out of bounds
				function Test:SetInteriorVehicleData_RowspanOutLowerBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = -1,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								circulateAirEnable = true,
								dualModeEnable = true,
								currentTemp = 30,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.4

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.5
			--Description: SetInteriorVehicleData with col parameter out of bounds
				function Test:SetInteriorVehicleData_ColOutLowerBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = -1,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								circulateAirEnable = true,
								dualModeEnable = true,
								currentTemp = 30,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.5

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.6
			--Description: SetInteriorVehicleData with levelspan parameter out of bounds
				function Test:SetInteriorVehicleData_LevelspanOutLowerBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = -1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								circulateAirEnable = true,
								dualModeEnable = true,
								currentTemp = 30,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.6

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.7
			--Description: SetInteriorVehicleData with level parameter out of bounds
				function Test:SetInteriorVehicleData_levelOutLowerBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = -1
							},
							climateControlData =
							{
								fanSpeed = 50,
								circulateAirEnable = true,
								dualModeEnable = true,
								currentTemp = 30,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.7

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.8
			--Description: SetInteriorVehicleData with frequencyInteger parameter out of bounds
				function Test:SetInteriorVehicleData_FrequencyIntegerOutLowerBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = -1,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.8

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.9
			--Description: SetInteriorVehicleData with frequencyFraction parameter out of bounds
				function Test:SetInteriorVehicleData_FrequencyFractionOutLowerBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = -1,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.9

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.10
			--Description: SetInteriorVehicleData with hdChannel parameter out of bounds
				function Test:SetInteriorVehicleData_HdChannelOutLowerBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 0,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.10

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.11
			--Description: SetInteriorVehicleData with availableHDs parameter out of bounds
				function Test:SetInteriorVehicleData_AvailableHDsOutLowerBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 0,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.11

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.12
			--Description: SetInteriorVehicleData with signalStrength parameter out of bounds
				function Test:SetInteriorVehicleData_SignalStrengthOutLowerBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = -1,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.12

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.13
			--Description: SetInteriorVehicleData with signalChangeThreshold parameter out of bounds
				function Test:SetInteriorVehicleData_SignalChangeThresholdOutLowerBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = -1
							},
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.13

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.14
			--Description: SetInteriorVehicleData with fanSpeed parameter out of bounds
				function Test:SetInteriorVehicleData_FanSpeedOutLowerBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = -1,
								circulateAirEnable = true,
								dualModeEnable = true,
								currentTemp = 30,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.14

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.15
			--Description: SetInteriorVehicleData with currentTemp parameter out of bounds
				function Test:SetInteriorVehicleData_CurrentTempOutLowerBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								circulateAirEnable = true,
								dualModeEnable = true,
								currentTemp = -1,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.15

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.16
			--Description: SetInteriorVehicleData with desiredTemp parameter out of bounds
				function Test:SetInteriorVehicleData_DesiredTempOutLowerBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								circulateAirEnable = true,
								dualModeEnable = true,
								currentTemp = 30,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = -1,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.16

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.17
			--Description: SetInteriorVehicleData with all parameters out of bounds
				function Test:SetInteriorVehicleData_AllParamsOutUpperBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								colspan = 101,
								row = 101,
								rowspan = 101,
								col = 101,
								levelspan = 101,
								level = 101
							},
							climateControlData =
							{
								fanSpeed = 101,
								circulateAirEnable = true,
								dualModeEnable = true,
								currentTemp = 101,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 101,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.17

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.18
			--Description: SetInteriorVehicleData with Colspan parameter out of bounds
				function Test:SetInteriorVehicleData_ColspanOutUpperBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 101,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.18

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.19
			--Description: SetInteriorVehicleData with row parameter out of bounds
				function Test:SetInteriorVehicleData_RowOutUpperBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								row = 101,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.19

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.20
			--Description: SetInteriorVehicleData with rowspan parameter out of bounds
				function Test:SetInteriorVehicleData_RowspanOutUpperBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 101,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.20

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.21
			--Description: SetInteriorVehicleData with col parameter out of bounds
				function Test:SetInteriorVehicleData_ColOutUpperBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 101,
								levelspan = 1,
								level = 0
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.21

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.22
			--Description: SetInteriorVehicleData with levelspan parameter out of bounds
				function Test:SetInteriorVehicleData_LevelspanOutUpperBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 101,
								level = 0
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.22

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.23
			--Description: SetInteriorVehicleData with level parameter out of bounds
				function Test:SetInteriorVehicleData_levelOutUpperBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 101
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.23

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.24
			--Description: SetInteriorVehicleData with frequencyInteger parameter out of bounds
				function Test:SetInteriorVehicleData_FrequencyIntegerOutUpperBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 1711,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.24

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.25
			--Description: SetInteriorVehicleData with frequencyFraction parameter out of bounds
				function Test:SetInteriorVehicleData_FrequencyFractionOutUpperBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 10,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.25

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.26
			--Description: SetInteriorVehicleData with hdChannel parameter out of bounds
				function Test:SetInteriorVehicleData_HdChannelOutUpperBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 4,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.26

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.27
			--Description: SetInteriorVehicleData with availableHDs parameter out of bounds
				function Test:SetInteriorVehicleData_AvailableHDsOutUpperBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 4,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.27

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.28
			--Description: SetInteriorVehicleData with signalStrength parameter out of bounds
				function Test:SetInteriorVehicleData_SignalStrengthOutUpperBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 101,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.28

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.29
			--Description: SetInteriorVehicleData with signalChangeThreshold parameter out of bounds
				function Test:SetInteriorVehicleData_SignalChangeThresholdOutUpperBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 101
							},
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.29

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.30
			--Description: SetInteriorVehicleData with fanSpeed parameter out of bounds
				function Test:SetInteriorVehicleData_FanSpeedOutUpperBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 101,
								circulateAirEnable = true,
								dualModeEnable = true,
								currentTemp = 30,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.30

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.31
			--Description: SetInteriorVehicleData with currentTemp parameter out of bounds
				function Test:SetInteriorVehicleData_CurrentTempOutUpperBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								circulateAirEnable = true,
								dualModeEnable = true,
								currentTemp = 101,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.31

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.32
			--Description: SetInteriorVehicleData with desiredTemp parameter out of bounds
				function Test:SetInteriorVehicleData_DesiredTempOutUpperBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								circulateAirEnable = true,
								dualModeEnable = true,
								currentTemp = 30,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 101,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.32

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.33
			--Description: SetInteriorVehicleData with CT parameter out of bounds
				function Test:SetInteriorVehicleData_CTOutLowerBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-070",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								clospan = 1,
								row = 1,
								rowspan = 1,
								col = 1,
								levelspan = 1,
								level = 1
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.33

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.34
			--Description: SetInteriorVehicleData with PTY parameter out of bounds
				function Test:SetInteriorVehicleData_PTYOutLowerBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = -1,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								clospan = 1,
								row = 1,
								rowspan = 1,
								col = 1,
								levelspan = 1,
								level = 1
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.34

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.35
			--Description: SetInteriorVehicleData with PS parameter out of bounds
				function Test:SetInteriorVehicleData_PSOutUpperBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "123456789",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								clospan = 1,
								row = 1,
								rowspan = 1,
								col = 1,
								levelspan = 1,
								level = 1
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.35

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.36
			--Description: SetInteriorVehicleData with PI parameter out of bounds
				function Test:SetInteriorVehicleData_PIOutUpperBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdentI",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								clospan = 1,
								row = 1,
								rowspan = 1,
								col = 1,
								levelspan = 1,
								level = 1
							}
						}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.36

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.37
			--Description: SetInteriorVehicleData with RT parameter out of bounds
				function Test:SetInteriorVehicleData_RTOutUpperBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData =
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "RADIO TEXT Minlength = 0, Maxlength = 64 RADIO TEXT Minlength = 6",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
											},
											signalChangeThreshold = 10
										},
										moduleType = "RADIO",
										moduleZone =
										{
											colspan = 2,
											row = 0,
											rowspan = 2,
											col = 0,
											levelspan = 1,
											level = 0
										}
									}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.37

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.38
			--Description: SetInteriorVehicleData with CT parameter out of bounds
				function Test:SetInteriorVehicleData_CTOutUpperBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
												moduleData =
									{
										radioControlData =
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-07009",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
											},
											signalChangeThreshold = 10
										},
										moduleType = "RADIO",
										moduleZone =
										{
											colspan = 2,
											row = 0,
											rowspan = 2,
											col = 0,
											levelspan = 1,
											level = 0
										}
									}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.2.38

	--End Test case CommonRequestCheck.2

		-----------------------------------------------------------------------------------------

	--Begin Test case CommonRequestCheck.3
	--Description: 	--invalid json
					--[REVSDL-932]: 4. Wrong json

		--Requirement/Diagrams id in jira:
				--REVSDL-932
				--REVSDL-939
				--https://adc.luxoft.com/jira/secure/attachment/115813/115813_Req_1_4_REVSDL-932.png

		--Verification criteria:
				--In case app sends RPC in wrong JSON, RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app

			--Begin Test case CommonRequestCheck.3.1
			--Description: Request with invalid JSON syntax (INVALID_DATA)
				function Test:SetInteriorVehicleData_InvalidJson()
				  self.mobileSession.correlationId = self.mobileSession.correlationId + 1

				  local msg =
				  {
					serviceType      = 7,
					frameInfo        = 0,
					rpcType          = 0,
					rpcFunctionId    = 100018,
					rpcCorrelationId = self.mobileSession.correlationId,
					payload          = '{"moduleData":{"radioControlData":{"radioEnable":true,"frequencyInteger":105,"frequencyFraction":3,"band":"AM","hdChannel":1,"state":"ACQUIRED","availableHDs":1,"signalStrength":50,"rdsData":{"PS":"12345678","RT":"Radio text minlength = 0, maxlength = 64","CT":"2015-09-29T18:46:19-07009","PI":"PIdent","PTY":0,"TP":true,"TA":false,"REG":"donot mention min,max length"},"signalChangeThreshold":10},"moduleType":"RADIO","moduleZone":{"colspan":2,"row":0,"rowspan":2,"col":0,"levelspan":1,"level"0}}}'
				  }
				  self.mobileSession:Send(msg)
				  self.mobileSession:ExpectResponse(self.mobileSession.correlationId, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.3.1

	--End Test case CommonRequestCheck.3

		-----------------------------------------------------------------------------------------

	--Begin Test case CommonRequestCheck.4
	--Description: 	--invalid json
					--[REVSDL-932]: 5. String with invalid characters

		--Requirement/Diagrams id in jira:
				--REVSDL-932
				--REVSDL-940
				--https://adc.luxoft.com/jira/secure/attachment/115818/115818_Req_1_5_of_REVSDL-932.png

		--Verification criteria:
				--In case app sends RPC with invalid characters in param of string type, RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app

		--SKIPPED because "Note: currently none of the listed RPCs has a string param." cloned to REVSDL-1005 [REVSDL-932]: 6. Parameter of wrong type

	--End Test case CommonRequestCheck.4

		-----------------------------------------------------------------------------------------

	--Begin Test case CommonRequestCheck.5
	--Description: 	--param of wrong type
					--[REVSDL-932]: 6. Parameter of wrong type

		--Requirement/Diagrams id in jira:
				--REVSDL-932
				--REVSDL-941
				--https://adc.luxoft.com/jira/secure/attachment/115819/115819_Req_1_6_of_REVSDL-932.png

		--Verification criteria:
				--In case app sends RPC with param of wrong type, RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app

			--Begin Test case CommonRequestCheck.5.1
			--Description: SetInteriorVehicleData with all parameters of wrong type
				function Test:SetInteriorVehicleData_AllParamsWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData =
										{
											radioEnable = "true",
											frequencyInteger = "105",
											frequencyFraction = "3",
											band = true,
											hdChannel = "1",
											state = 123,
											availableHDs = "1",
											signalStrength = "50",
											rdsData =
											{
												PS = 12345678,
												RT = false,
												CT = 123456789123456789123456,
												PI = true,
												PTY = "0",
												TP = "true",
												TA = "false",
												REG = 123
											},
											signalChangeThreshold = "10"
										},
										moduleType = true,
										moduleZone =
										{
											colspan = "2",
											row = "0",
											rowspan = "2",
											col = "0",
											levelspan = "1",
											level = "0"
										}
									}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.2
			--Description: SetInteriorVehicleData with radioEnable parameter of wrong type
				function Test:SetInteriorVehicleData_RadioEnableWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData =
										{
											radioEnable = 123,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
											},
											signalChangeThreshold = 10
										},
										moduleType = "RADIO",
										moduleZone =
										{
											colspan = 2,
											row = 0,
											rowspan = 2,
											col = 0,
											levelspan = 1,
											level = 0
										}
									}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.3
			--Description: SetInteriorVehicleData with frequencyInteger parameter of wrong type
				function Test:SetInteriorVehicleData_FrequencyIntegerWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData =
										{
											radioEnable = true,
											frequencyInteger = "105",
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
											},
											signalChangeThreshold = 10
										},
										moduleType = "RADIO",
										moduleZone =
										{
											colspan = 2,
											row = 0,
											rowspan = 2,
											col = 0,
											levelspan = 1,
											level = 0
										}
									}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.3

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.4
			--Description: SetInteriorVehicleData with frequencyFraction parameter of wrong type
				function Test:SetInteriorVehicleData_FrequencyFractionWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData =
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = "3",
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
											},
											signalChangeThreshold = 10
										},
										moduleType = "RADIO",
										moduleZone =
										{
											colspan = 2,
											row = 0,
											rowspan = 2,
											col = 0,
											levelspan = 1,
											level = 0
										}
									}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.4

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.5
			--Description: SetInteriorVehicleData with band parameter of wrong type
				function Test:SetInteriorVehicleData_BandWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData =
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = 123,
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
											},
											signalChangeThreshold = 10
										},
										moduleType = "RADIO",
										moduleZone =
										{
											colspan = 2,
											row = 0,
											rowspan = 2,
											col = 0,
											levelspan = 1,
											level = 0
										}
									}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.5

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.6
			--Description: SetInteriorVehicleData with hdChannel parameter of wrong type
				function Test:SetInteriorVehicleData_HdChannelWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData =
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = "1",
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
											},
											signalChangeThreshold = 10
										},
										moduleType = "RADIO",
										moduleZone =
										{
											colspan = 2,
											row = 0,
											rowspan = 2,
											col = 0,
											levelspan = 1,
											level = 0
										}
									}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.6

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.7
			--Description: SetInteriorVehicleData with state parameter of wrong type
				function Test:SetInteriorVehicleData_StateWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData =
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = true,
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
											},
											signalChangeThreshold = 10
										},
										moduleType = "RADIO",
										moduleZone =
										{
											colspan = 2,
											row = 0,
											rowspan = 2,
											col = 0,
											levelspan = 1,
											level = 0
										}
									}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.7

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.8
			--Description: SetInteriorVehicleData with availableHDs parameter of wrong type
				function Test:SetInteriorVehicleData_AvailableHDsWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData =
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = "1",
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
											},
											signalChangeThreshold = 10
										},
										moduleType = "RADIO",
										moduleZone =
										{
											colspan = 2,
											row = 0,
											rowspan = 2,
											col = 0,
											levelspan = 1,
											level = 0
										}
									}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.8

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.9
			--Description: SetInteriorVehicleData with signalStrength parameter of wrong type
				function Test:SetInteriorVehicleData_SignalStrengthWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData =
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = "50",
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
											},
											signalChangeThreshold = 10
										},
										moduleType = "RADIO",
										moduleZone =
										{
											colspan = 2,
											row = 0,
											rowspan = 2,
											col = 0,
											levelspan = 1,
											level = 0
										}
									}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.9

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.10
			--Description: SetInteriorVehicleData with PS parameter of wrong type
				function Test:SetInteriorVehicleData_PSWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData =
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = 12345678,
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
											},
											signalChangeThreshold = 10
										},
										moduleType = "RADIO",
										moduleZone =
										{
											colspan = 2,
											row = 0,
											rowspan = 2,
											col = 0,
											levelspan = 1,
											level = 0
										}
									}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.10

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.11
			--Description: SetInteriorVehicleData with RT parameter of wrong type
				function Test:SetInteriorVehicleData_RTWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData =
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = 123,
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
											},
											signalChangeThreshold = 10
										},
										moduleType = "RADIO",
										moduleZone =
										{
											colspan = 2,
											row = 0,
											rowspan = 2,
											col = 0,
											levelspan = 1,
											level = 0
										}
									}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.11

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.12
			--Description: SetInteriorVehicleData with CT parameter of wrong type
				function Test:SetInteriorVehicleData_CTWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData =
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = 123456789123456789123456,
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
											},
											signalChangeThreshold = 10
										},
										moduleType = "RADIO",
										moduleZone =
										{
											colspan = 2,
											row = 0,
											rowspan = 2,
											col = 0,
											levelspan = 1,
											level = 0
										}
									}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.12

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.13
			--Description: SetInteriorVehicleData with PI parameter of wrong type
				function Test:SetInteriorVehicleData_PIWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData =
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = false,
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
											},
											signalChangeThreshold = 10
										},
										moduleType = "RADIO",
										moduleZone =
										{
											colspan = 2,
											row = 0,
											rowspan = 2,
											col = 0,
											levelspan = 1,
											level = 0
										}
									}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.13

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.14
			--Description: SetInteriorVehicleData with PTY parameter of wrong type
				function Test:SetInteriorVehicleData_PTYWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData =
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = "0",
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
											},
											signalChangeThreshold = 10
										},
										moduleType = "RADIO",
										moduleZone =
										{
											colspan = 2,
											row = 0,
											rowspan = 2,
											col = 0,
											levelspan = 1,
											level = 0
										}
									}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.14

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.15
			--Description: SetInteriorVehicleData with TP parameter of wrong type
				function Test:SetInteriorVehicleData_TPWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData =
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = "true",
												TA = false,
												REG = "don't mention min,max length"
											},
											signalChangeThreshold = 10
										},
										moduleType = "RADIO",
										moduleZone =
										{
											colspan = 2,
											row = 0,
											rowspan = 2,
											col = 0,
											levelspan = 1,
											level = 0
										}
									}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.15

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.16
			--Description: SetInteriorVehicleData with TA parameter of wrong type
				function Test:SetInteriorVehicleData_TAWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData =
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = "false",
												REG = "don't mention min,max length"
											},
											signalChangeThreshold = 10
										},
										moduleType = "RADIO",
										moduleZone =
										{
											colspan = 2,
											row = 0,
											rowspan = 2,
											col = 0,
											levelspan = 1,
											level = 0
										}
									}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.16

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.17
			--Description: SetInteriorVehicleData with REG parameter of wrong type
				function Test:SetInteriorVehicleData_REGWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData =
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = 123
											},
											signalChangeThreshold = 10
										},
										moduleType = "RADIO",
										moduleZone =
										{
											colspan = 2,
											row = 0,
											rowspan = 2,
											col = 0,
											levelspan = 1,
											level = 0
										}
									}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.17

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.18
			--Description: SetInteriorVehicleData with signalChangeThreshold parameter of wrong type
				function Test:SetInteriorVehicleData_SignalChangeThresholdWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData =
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
											},
											signalChangeThreshold = "10"
										},
										moduleType = "RADIO",
										moduleZone =
										{
											colspan = 2,
											row = 0,
											rowspan = 2,
											col = 0,
											levelspan = 1,
											level = 0
										}
									}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.18

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.19
			--Description: SetInteriorVehicleData with moduleType parameter of wrong type
				function Test:SetInteriorVehicleData_ModuleTypeWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData =
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
											},
											signalChangeThreshold = 10
										},
										moduleType = true,
										moduleZone =
										{
											colspan = 2,
											row = 0,
											rowspan = 2,
											col = 0,
											levelspan = 1,
											level = 0
										}
									}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.19

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.20
			--Description: SetInteriorVehicleData with clospan parameter of wrong type
				function Test:SetInteriorVehicleData_ClospanWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData =
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
											},
											signalChangeThreshold = 10
										},
										moduleType = "RADIO",
										moduleZone =
										{
											colspan = "2",
											row = 0,
											rowspan = 2,
											col = 0,
											levelspan = 1,
											level = 0
										}
									}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.20

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.21
			--Description: SetInteriorVehicleData with row parameter of wrong type
				function Test:SetInteriorVehicleData_RowWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData =
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
											},
											signalChangeThreshold = 10
										},
										moduleType = "RADIO",
										moduleZone =
										{
											colspan = 2,
											row = "0",
											rowspan = 2,
											col = 0,
											levelspan = 1,
											level = 0
										}
									}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.21

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.22
			--Description: SetInteriorVehicleData with rowspan parameter of wrong type
				function Test:SetInteriorVehicleData_RowspanWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData =
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
											},
											signalChangeThreshold = 10
										},
										moduleType = "RADIO",
										moduleZone =
										{
											colspan = 2,
											row = 0,
											rowspan = "2",
											col = 0,
											levelspan = 1,
											level = 0
										}
									}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.22

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.23
			--Description: SetInteriorVehicleData with col parameter of wrong type
				function Test:SetInteriorVehicleData_ColWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData =
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
											},
											signalChangeThreshold = 10
										},
										moduleType = "RADIO",
										moduleZone =
										{
											colspan = 2,
											row = 0,
											rowspan = 2,
											col = "0",
											levelspan = 1,
											level = 0
										}
									}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.23

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.24
			--Description: SetInteriorVehicleData with levelspan parameter of wrong type
				function Test:SetInteriorVehicleData_LevelspanWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData =
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
											},
											signalChangeThreshold = 10
										},
										moduleType = "RADIO",
										moduleZone =
										{
											colspan = 2,
											row = 0,
											rowspan = 2,
											col = 0,
											levelspan = "1",
											level = 0
										}
									}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.24

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.25
			--Description: SetInteriorVehicleData with level parameter of wrong type
				function Test:SetInteriorVehicleData_LevelWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData =
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
											},
											signalChangeThreshold = 10
										},
										moduleType = "RADIO",
										moduleZone =
										{
											colspan = 2,
											row = 0,
											rowspan = 2,
											col = 0,
											levelspan = 1,
											level = "0"
										}
									}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.25

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.26
			--Description: SetInteriorVehicleData with fanSpeed parameter of wrong type
				function Test:SetInteriorVehicleData_FanSpeedWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = "50",
								circulateAirEnable = true,
								dualModeEnable = true,
								currentTemp = 30,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
						})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.26

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.27
			--Description: SetInteriorVehicleData with circulateAirEnable parameter of wrong type
				function Test:SetInteriorVehicleData_CirculateAirEnableWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								circulateAirEnable = "true",
								dualModeEnable = true,
								currentTemp = 30,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
						})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.27

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.28
			--Description: SetInteriorVehicleData with dualModeEnable parameter of wrong type
				function Test:SetInteriorVehicleData_DualModeEnableWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								circulateAirEnable = true,
								dualModeEnable = "true",
								currentTemp = 30,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
						})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.28

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.29
			--Description: SetInteriorVehicleData with currentTemp parameter of wrong type
				function Test:SetInteriorVehicleData_CurrentTempWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								circulateAirEnable = true,
								dualModeEnable = true,
								currentTemp = false,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
						})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.29

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.30
			--Description: SetInteriorVehicleData with defrostZone parameter of wrong type
				function Test:SetInteriorVehicleData_DefrostZoneWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								circulateAirEnable = true,
								dualModeEnable = true,
								currentTemp = 30,
								defrostZone = 123,
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
						})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.30

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.31
			--Description: SetInteriorVehicleData with acEnable parameter of wrong type
				function Test:SetInteriorVehicleData_AcEnableWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								circulateAirEnable = true,
								dualModeEnable = true,
								currentTemp = 30,
								defrostZone = "FRONT",
								acEnable = "true",
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
						})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.31

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.32
			--Description: SetInteriorVehicleData with desiredTemp parameter of wrong type
				function Test:SetInteriorVehicleData_DesiredTempWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								circulateAirEnable = true,
								dualModeEnable = true,
								currentTemp = 30,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = "24",
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
						})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.32

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.33
			--Description: SetInteriorVehicleData with autoModeEnable parameter of wrong type
				function Test:SetInteriorVehicleData_AutoModeEnableWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								circulateAirEnable = true,
								dualModeEnable = true,
								currentTemp = 30,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = 123,
								temperatureUnit = "CELSIUS"
							}
						}
						})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.33

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.34
			--Description: SetInteriorVehicleData with TemperatureUnit parameter of wrong type
				function Test:SetInteriorVehicleData_TemperatureUnitWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								circulateAirEnable = true,
								dualModeEnable = true,
								currentTemp = 30,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = 123
							}
						}
						})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.34

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.35
			--Description: SetInteriorVehicleData with moduleData parameter of wrong type
				function Test:SetInteriorVehicleData_ModuleDataWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = "abc"
						})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.35

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.36
			--Description: SetInteriorVehicleData with climateControlData parameter of wrong type
				function Test:SetInteriorVehicleData_ClimateControlDataWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData = "  a b c  "
						}
						})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.36

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.37
			--Description: SetInteriorVehicleData with radioControlData parameter of wrong type
				function Test:SetInteriorVehicleData_RadioControlDataDataWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = true,
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}
						})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.37

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.37
			--Description: SetInteriorVehicleData with moduleZone parameter of wrong type
				function Test:SetInteriorVehicleData_ModuleZoneDataDataWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone = true
						}
						})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.37

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.38
			--Description: SetInteriorVehicleData with rdsData parameter of wrong type
				function Test:SetInteriorVehicleData_RdsDataWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData =
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData = true,
											signalChangeThreshold = 10
										},
										moduleType = "RADIO",
										moduleZone =
										{
											colspan = 2,
											row = 0,
											rowspan = 2,
											col = 0,
											levelspan = 1,
											level = 0
										}
									}
					})

					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.5.38

	--End Test case CommonRequestCheck.5

		-----------------------------------------------------------------------------------------

	--Begin Test case CommonRequestCheck.6
	--Description: 	--RSDL cuts off the fake param (non-existent per Mobile_API) from app's RPC.
					--[REVSDL-932]: 7. Fake params

		--Requirement/Diagrams id in jira:
				--REVSDL-932
				--REVSDL-997
				--https://adc.luxoft.com/jira/secure/attachment/116227/116227_Req_1_2_7_of_REVSDL-932.png

		--Verification criteria:
				--In case app sends RPC with fake param (non-existent per Mobile_API), RSDL must cut this param off from the RPC and then validate this RPC and process as assigned.

			--Begin Test case CommonRequestCheck.6.1
			--Description: app sends RPC with fake param inside radioControlData
				function Test:SetInteriorVehicleData_FakeParamsInsideRadioControlData()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								fake1 = true,
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								fake2 = 123,
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "",
									CT = "123456789012345678901234",
									PI = "",
									PTY = 0,
									TP = true,
									TA = false,
									REG = ""
								},
								fake3 = "123",
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}
					})

				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData")
				:ValidIf (function(_,data)
						if data.params.moduleData.radioControlData.fake1 or data.params.moduleData.radioControlData.fake2 or data.params.moduleData.radioControlData.fake3 then
							print(" --SDL sends fake parameter to HMI ")
							for key,value in pairs(data.params.moduleData.radioControlData) do print(key,value) end
							return false
						else
							return true
						end
					end)
					:Timeout(3000)

				end
			--End Test case CommonRequestCheck.6.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.6.2
			--Description: app sends RPC with fake param inside rdsData
						--Updating base on REVSDL-1702(Req#3: REVSDL-1715), cut readonly parameters
				function Test:SetInteriorVehicleData_FakeParamsInsideRdsData()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									fake1 = false,
									PS = "12345678",
									RT = "",
									fake2 = "fakeparameters",
									CT = "123456789012345678901234",
									PI = "",
									PTY = 0,
									TP = true,
									TA = false,
									fake3 = 123,
									REG = ""
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}
					})

				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData")
				:ValidIf (function(_,data)
						if data.params.moduleData.radioControlData.rdsData or data.params.moduleData.radioControlData.rdsData or data.params.moduleData.radioControlData.rdsData then
							print(" --SDL sends fake parameter to HMI ")
							for key,value in pairs(data.params.moduleData.radioControlData) do print(key,value) end
							return false
						else
							return true
						end
					end)
					:Timeout(3000)

				end
			--End Test case CommonRequestCheck.6.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.6.3
			--Description: app sends RPC with fake param inside moduleZone
				function Test:SetInteriorVehicleData_FakeParamsInsideModuleZone()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData =
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "",
									CT = "123456789012345678901234",
									PI = "",
									PTY = 0,
									TP = true,
									TA = false,
									REG = ""
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone =
							{
								colspan = 2,
								fake1 = "  fake parameters  ",
								row = 0,
								fake2 = false,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								fake3 = 123,
								level = 0
							}
						}
					})

				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData")
				:ValidIf (function(_,data)
						if data.params.moduleData.moduleZone.fake1 or data.params.moduleData.moduleZone.fake2 or data.params.moduleData.moduleZone.fake3 then
							print(" --SDL sends fake parameter to HMI ")
							for key,value in pairs(data.params.moduleData.moduleZone) do print(key,value) end
							return false
						else
							return true
						end
					end)
					:Timeout(3000)

				end
			--End Test case CommonRequestCheck.6.3

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.6.4
			--Description: app sends RPC with fake param inside climateControlData
				function Test:SetInteriorVehicleData_FakeParamsInsideClimateControlData()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone =
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fake1 = true,
								fanSpeed = 50,
								circulateAirEnable = true,
								dualModeEnable = true,
								currentTemp = 30,
								fake2 = 123,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								fake3 = "  fake parameter  ",
								temperatureUnit = "CELSIUS"
							}
						}
					})

				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData")
				:ValidIf (function(_,data)
						if data.params.moduleData.climateControlData.fake1 or data.params.moduleData.climateControlData.fake2 or data.params.moduleData.climateControlData.fake3 then
							print(" --SDL sends fake parameter to HMI ")
							for key,value in pairs(data.params.moduleData.climateControlData) do print(key,value) end
							return false
						else
							return true
						end
					end)
					:Timeout(3000)

				end
			--End Test case CommonRequestCheck.6.4

	--End Test case CommonRequestCheck.6

--=================================================END TEST CASES 4==========================================================--



return Test