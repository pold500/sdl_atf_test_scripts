local commonPreconditions = require("user_modules/shared_testcases/commonPreconditions")
commonPreconditions:BackupFile("sdl_preloaded_pt.json")
commonPreconditions:ReplaceFile("sdl_preloaded_pt.json", "./test_scripts/RC/TestData/sdl_preloaded_pt.json")

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

--List permission of "OnPermissionsChange" for PrimaryDevice and NonPrimaryDevice
--groups_PrimaryRC Group
local arrayGroups_PrimaryRC = revsdl.arrayGroups_PrimaryRC()
--groups_nonPrimaryRC Group
local arrayGroups_nonPrimaryRC = revsdl.arrayGroups_nonPrimaryRC()


--======================================REVSDL-1577========================================--
---------------------------------------------------------------------------------------------
--------------REVSDL-1577: A device previously set as "driver's" must be---------------------
------------------------------ switchable to "passenger's"-----------------------------------
---------------------------------------------------------------------------------------------
--=========================================================================================--

--=================================================BEGIN TEST CASES 3==========================================================--
  --Begin Test suit CommonRequestCheck.3 for Req.#3 (TCs: REVSDL-1617 - [REVSDL-1577][TC-05]: RSDL sets device as passenger in case receiving RC.OnDeviceRankChanged ("PASSENGER", deviceID))

  --Description: In case RSDL knows a device to be driver's and RC.OnDeviceRankChanged ("PASSENGER", deviceID) for the same device comes from HMI, RSDL must set this device as passenger's


  --Begin Test case CommonRequestCheck.3.1
  --Description:  In case RSDL knows a device to be driver's and RC.OnDeviceRankChanged ("PASSENGER", deviceID) for the same device comes from HMI, RSDL must set this device as passenger's


    --Requirement/Diagrams id in jira:
        --REVSDL-1577

    --Verification criteria:
        --In case RSDL knows a device to be driver's and RC.OnDeviceRankChanged ("PASSENGER", deviceID) for the same device comes from HMI, RSDL must set this device as passenger's

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.3.1.1
      --Description: Set device1 to Driver's device from HMI
        function Test:OnDeviceRankChanged_Driver()

          --hmi side: send request RC.OnDeviceRankChanged
          self.hmiConnection:SendNotification("RC.OnDeviceRankChanged",
                              {deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})

          --mobile side: Expect OnPermissionsChange notification for Driver's device
          EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_PrimaryRC )

          --mobile side: OnHMIStatus notifications with deviceRank = "DRIVER"
          EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })

        end
      --End Test case CommonRequestCheck.3.1.1

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.3.1.2
      --Description: Set device1 to Passenger's device from HMI
        function Test:OnDeviceRankChanged_DriverToPassenger()

          --hmi side: send request RC.OnDeviceRankChanged
          self.hmiConnection:SendNotification("RC.OnDeviceRankChanged",
                              {deviceRank = "PASSENGER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})

          --mobile side: Expect OnPermissionsChange notification for Passenger's device
          EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_nonPrimaryRC )

          --mobile side: OnHMIStatus notifications with deviceRank = "PASSENGER"
          EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })

        end
      --End Test case CommonRequestCheck.3.1.2

    -----------------------------------------------------------------------------------------
  --End Test case CommonRequestCheck.3.1


  --Begin Test case CommonRequestCheck.3.2
  --Description:  In case RSDL knows a device to be driver's and RC.OnDeviceRankChanged ("PASSENGER", deviceID) for the same device comes from HMI, RSDL must set this device as passenger's


    --Requirement/Diagrams id in jira:
        --REVSDL-1577
        --TC: REVSDL-1619

    --Verification criteria:
        --In case RSDL knows a device to be driver's and RC.OnDeviceRankChanged ("PASSENGER", deviceID) for the same device comes from HMI, RSDL must set this device as passenger's

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.3.2.1
      --Description: Set device1 to Driver's device from HMI
        function Test:TC3_Driver()

          --hmi side: send request RC.OnDeviceRankChanged
          self.hmiConnection:SendNotification("RC.OnDeviceRankChanged",
                              {deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})

          --mobile side: Expect OnPermissionsChange notification for Driver's device
          EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_PrimaryRC )

          --mobile side: OnHMIStatus notifications with deviceRank = "DRIVER"
          EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })

        end
      --End Test case CommonRequestCheck.3.2.1

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.3.2.2
      --Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO (SUCCESS)
        function Test:TC3_App1ButtonPress()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
          local cid = self.mobileSession:SendRPC("ButtonPress",
          {
            zone =
            {
              colspan = 2,
              row = 0,
              rowspan = 2,
              col = 1,
              levelspan = 1,
              level = 0
            },
            moduleType = "RADIO",
            buttonPressMode = "LONG",
            buttonName = "VOLUME_UP"
          })

          --hmi side: expect Buttons.ButtonPress request
          EXPECT_HMICALL("Buttons.ButtonPress",
                  {
                    zone =
                    {
                      colspan = 2,
                      row = 0,
                      rowspan = 2,
                      col = 1,
                      levelspan = 1,
                      level = 0
                    },
                    moduleType = "RADIO",
                    buttonPressMode = "LONG",
                    buttonName = "VOLUME_UP"
                  })
            :Do(function(_,data)
              --hmi side: sending Buttons.ButtonPress response
              self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
            end)

          --App_1 recevies SUCCESS.
          EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
        end
      --End Test case CommonRequestCheck.3.2.2

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.3.2.3
      --Description: activate App1 to FULL
        function Test:TC3_App1FULL()

          --hmi side: sending SDL.ActivateApp request
          local rid = self.hmiConnection:SendRequest("SDL.ActivateApp",
                                { appID = self.applications["Test Application"] })

          --hmi side: Waiting for SDL.ActivateApp response
          EXPECT_HMIRESPONSE(rid)
          self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "FULL"})
        end
      --End Test case CommonRequestCheck.3.2.3

    -----------------------------------------------------------------------------------------

    --Begin Test case CommonRequestCheck.3.2.4
      --Description: Positive case and in boundary conditions (SUCCESS)
      function Test:TC3_ShowUI_SUCCESS()

        --mobile side: sending Show request
        local cid = self.mobileSession:SendRPC("Show",
                            {
                              mainField1 = "Show Line 1"
                            })
        --hmi side: expect UI.Show request
        EXPECT_HMICALL("UI.Show",
                {

                  showStrings =
                  {
                    {
                    fieldName = "mainField1",
                    fieldText = "Show Line 1"
                    }
                  }
                })
          :Do(function(_,data)
            --hmi side: sending UI.Show response
            self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
          end)

        --mobile side: expect Show response SUCCESS
        EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })

      end
    --End Test case CommonRequestCheck.3.2.4

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.3.2.5
      --Description: Set device1 to Passenger's device from HMI
        function Test:TC3_DriverToPassenger()

          --hmi side: send request RC.OnDeviceRankChanged
          self.hmiConnection:SendNotification("RC.OnDeviceRankChanged",
                              {deviceRank = "PASSENGER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})

          --mobile side: Expect OnPermissionsChange notification for Passenger's device
          EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_nonPrimaryRC )

          --mobile side: OnHMIStatus notifications with deviceRank = "PASSENGER"
          EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", deviceRank = "PASSENGER" })

        end
      --End Test case CommonRequestCheck.3.2.5

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.3.2.6
      --Description: application sends ButtonPress as Front Passenger (driver_allow SUCCESS)
        function Test:TC3_App1DriverAllow()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
          local cid = self.mobileSession:SendRPC("ButtonPress",
          {
            zone =
            {
              colspan = 2,
              row = 0,
              rowspan = 2,
              col = 1,
              levelspan = 1,
              level = 0
            },
            moduleType = "RADIO",
            buttonPressMode = "LONG",
            buttonName = "VOLUME_UP"
          })

          --hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
          EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent",
                {
                  appID = self.applications["Test Application1"],
                  moduleType = "RADIO",
                  zone =
                  {
                    colspan = 2,
                    row = 0,
                    rowspan = 2,
                    col = 1,
                    levelspan = 1,
                    level = 0
                  }
                })
            :Do(function(_,data)
              --hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
              self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {allowed = true})

              --hmi side: expect Buttons.ButtonPress request
              EXPECT_HMICALL("Buttons.ButtonPress",
                      {
                        zone =
                        {
                          colspan = 2,
                          row = 0,
                          rowspan = 2,
                          col = 1,
                          levelspan = 1,
                          level = 0
                        },
                        moduleType = "RADIO",
                        buttonPressMode = "LONG",
                        buttonName = "VOLUME_UP"
                      })
                :Do(function(_,data)
                  --hmi side: sending Buttons.ButtonPress response
                  self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
                end)
            end)

          --App_1 recevies SUCCESS.
          EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
        end
      --End Test case CommonRequestCheck.3.2.6

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.3.2.7
      --Description: application sends ButtonPress as Driver (auto_allow SUCCESS)
        function Test:TC3_App1AutoAllow()
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
            moduleType = "RADIO",
            buttonPressMode = "LONG",
            buttonName = "VOLUME_UP"
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
                  moduleType = "RADIO",
                  buttonPressMode = "LONG",
                  buttonName = "VOLUME_UP"
                })
          :Do(function(_,data)
            --hmi side: sending Buttons.ButtonPress response
            self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
          end)

          EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
        end
      --End Test case CommonRequestCheck.3.2.7

    -----------------------------------------------------------------------------------------

    --Begin Test case CommonRequestCheck.3.2.4
      --Description: Positive case and in boundary conditions (DISALLOWED)
      function Test:TC3_ShowUI_DISALLOWED()

        --mobile side: sending Show request
        local cid = self.mobileSession:SendRPC("Show",
                            {
                              mainField1 = "Show Line 1"
                            })

        --mobile side: expect Show response DISALLOWED
        EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED" })

      end
    --End Test case CommonRequestCheck.3.2.4

    -----------------------------------------------------------------------------------------
  --End Test case CommonRequestCheck.3.2


  --Begin Test case CommonRequestCheck.3.3 (restart SDL before running this test suite)
  --Description:  In case RSDL knows a device to be driver's and RC.OnDeviceRankChanged ("PASSENGER", deviceID) for the same device comes from HMI, RSDL must set this device as passenger's


    --Requirement/Diagrams id in jira:
        --REVSDL-1577
        --TC: REVSDL-1620

    --Verification criteria:
        --In case RSDL knows a device to be driver's and RC.OnDeviceRankChanged ("PASSENGER", deviceID) for the same device comes from HMI, RSDL must set this device as passenger's

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.3.3.1
      --Description: application sends ButtonPress as Front Passenger (driver_allow SUCCESS)
        function Test:TC3_App1DriverAllow()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
          local cid = self.mobileSession:SendRPC("ButtonPress",
          {
            zone =
            {
              colspan = 2,
              row = 0,
              rowspan = 2,
              col = 1,
              levelspan = 1,
              level = 0
            },
            moduleType = "RADIO",
            buttonPressMode = "LONG",
            buttonName = "VOLUME_UP"
          })

          --hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
          EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent",
                {
                  appID = self.applications["Test Application1"],
                  moduleType = "RADIO",
                  zone =
                  {
                    colspan = 2,
                    row = 0,
                    rowspan = 2,
                    col = 1,
                    levelspan = 1,
                    level = 0
                  }
                })
            :Do(function(_,data)
              --hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
              self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {allowed = true})

              --hmi side: expect Buttons.ButtonPress request
              EXPECT_HMICALL("Buttons.ButtonPress",
                      {
                        zone =
                        {
                          colspan = 2,
                          row = 0,
                          rowspan = 2,
                          col = 1,
                          levelspan = 1,
                          level = 0
                        },
                        moduleType = "RADIO",
                        buttonPressMode = "LONG",
                        buttonName = "VOLUME_UP"
                      })
                :Do(function(_,data)
                  --hmi side: sending Buttons.ButtonPress response
                  self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
                end)
            end)

          --App_1 recevies SUCCESS.
          EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
        end
      --End Test case CommonRequestCheck.3.3.1

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.3.3.2
      --Description: application sends ButtonPress as Driver (auto_allow SUCCESS)
        function Test:TC3_App1AutoAllow()
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
            moduleType = "RADIO",
            buttonPressMode = "LONG",
            buttonName = "VOLUME_UP"
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
                  moduleType = "RADIO",
                  buttonPressMode = "LONG",
                  buttonName = "VOLUME_UP"
                })
          :Do(function(_,data)
            --hmi side: sending Buttons.ButtonPress response
            self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
          end)

          EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
        end
      --End Test case CommonRequestCheck.3.3.2

    -----------------------------------------------------------------------------------------

    --Begin Test case CommonRequestCheck.3.3.3
      --Description: Positive case and in boundary conditions (DISALLOWED)
      function Test:TC3_ShowUI_DISALLOWED()

        --mobile side: sending Show request
        local cid = self.mobileSession:SendRPC("Show",
                            {
                              mainField1 = "Show Line 1"
                            })

        --mobile side: expect Show response DISALLOWED
        EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED" })

      end
    --End Test case CommonRequestCheck.3.3.3

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.3.3.4
      --Description: Set device1 to Driver's device from HMI
        function Test:TC3_Driver()

          --hmi side: send request RC.OnDeviceRankChanged
          self.hmiConnection:SendNotification("RC.OnDeviceRankChanged",
                              {deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})

          --mobile side: Expect OnPermissionsChange notification for Driver's device
          EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_PrimaryRC )

          --mobile side: OnHMIStatus notifications with deviceRank = "DRIVER"
          EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "LIMITED", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })

        end
      --End Test case CommonRequestCheck.3.3.4

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.3.3.5
      --Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO (SUCCESS)
        function Test:TC3_App1ButtonPress()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
          local cid = self.mobileSession:SendRPC("ButtonPress",
          {
            zone =
            {
              colspan = 2,
              row = 0,
              rowspan = 2,
              col = 1,
              levelspan = 1,
              level = 0
            },
            moduleType = "RADIO",
            buttonPressMode = "LONG",
            buttonName = "VOLUME_UP"
          })

          --hmi side: expect Buttons.ButtonPress request
          EXPECT_HMICALL("Buttons.ButtonPress",
                  {
                    zone =
                    {
                      colspan = 2,
                      row = 0,
                      rowspan = 2,
                      col = 1,
                      levelspan = 1,
                      level = 0
                    },
                    moduleType = "RADIO",
                    buttonPressMode = "LONG",
                    buttonName = "VOLUME_UP"
                  })
            :Do(function(_,data)
              --hmi side: sending Buttons.ButtonPress response
              self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
            end)

          --App_1 recevies SUCCESS.
          EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
        end
      --End Test case CommonRequestCheck.3.3.5

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.3.3.6
      --Description: activate App1 to FULL
        function Test:TC3_App1FULL()

          --hmi side: sending SDL.ActivateApp request
          local rid = self.hmiConnection:SendRequest("SDL.ActivateApp",
                                { appID = self.applications["Test Application"] })

          --hmi side: Waiting for SDL.ActivateApp response
          EXPECT_HMIRESPONSE(rid)
          self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "FULL" })
        end
      --End Test case CommonRequestCheck.3.3.6

    -----------------------------------------------------------------------------------------

    --Begin Test case CommonRequestCheck.3.3.7
      --Description: Positive case and in boundary conditions (SUCCESS)
      function Test:TC3_ShowUI_SUCCESS()

        --mobile side: sending Show request
        local cid = self.mobileSession:SendRPC("Show",
                            {
                              mainField1 = "Show Line 1"
                            })
        --hmi side: expect UI.Show request
        EXPECT_HMICALL("UI.Show",
                {

                  showStrings =
                  {
                    {
                    fieldName = "mainField1",
                    fieldText = "Show Line 1"
                    }
                  }
                })
          :Do(function(_,data)
            --hmi side: sending UI.Show response
            self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
          end)

        --mobile side: expect Show response SUCCESS
        EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })

      end
    --End Test case CommonRequestCheck.3.3.7

    -----------------------------------------------------------------------------------------
  --End Test case CommonRequestCheck.3.3

--=================================================END TEST CASES 3==========================================================--

function Test:PostconditionsRestoreFile()
  commonPreconditions:RestoreFile("sdl_preloaded_pt.json")
end