--This script contains common functions that are used in many script.
--How to use:
  --1. local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
  --2. commonFunctions:createString(500) --example
---------------------------------------------------------------------------------------------
local commonFunctions = {}
local json = require('json4lua/json/json')

---------------------------------------------------------------------------------------------
------------------------------------------ Functions ----------------------------------------
---------------------------------------------------------------------------------------------
--List of group functions:
--1. Functions for String
--2. Functions for Table
--3. Functions for Test Case
--4. Functions for TTSChunk
--5. Functions for SoftButton
--6. Functions for printing error
--7. Functions for Response
--8. Functions for Notification
--9. Functions for checking the existence
--10. Functions for updated .ini file
--11. Function for updating PendingRequestsAmount in .ini file to test TOO_MANY_PENDING_REQUESTS resultCode
--12. Functions array of structures
--13. Functions for SDL stop
--14. Function gets parameter from smartDeviceLink.ini file
--15. Function sets parameter to smartDeviceLink.ini file
--16. Function transform data from PTU to permission change data
--17. Function returns data from sqlite by query
--18. Function checks value of column from DB with input data
---------------------------------------------------------------------------------------------

--return true if app is media or navigation
function commonFunctions:isMediaApp()

  local isMedia = false

  if Test.isMediaApplication == true or
    Test.appHMITypes["NAVIGATION"] == true  then
    isMedia = true
  end

  return isMedia

end

function commonFunctions:userPrint( color, message)
  print ("\27[" .. tostring(color) .. "m " .. tostring(message) .. " \27[0m")
end

--1. Functions for String
---------------------------------------------------------------------------------------------
function commonFunctions:createString(length)

  return string.rep("a", length)

end

function commonFunctions:createArrayString(size, length)

  if length == nil then
    length = 1
  end

  local temp = {}
  for i = 1, size do
    table.insert(temp, string.rep("a", length))
  end
  return temp

end


function commonFunctions:createArrayInteger(size, value)

  if value == nil then
    value = 1
  end

  local temp = {}
  for i = 1, size do
    table.insert(temp, value)
  end
  return temp

end
---------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------
--2. Functions for Table
---------------------------------------------------------------------------------------------

--Convert a table to string
function commonFunctions:convertTableToString (tbl, i)
  local strIndex = ""
  local strIndex2 = ""
  local strReturn = ""
  for j = 1, i do
    strIndex = strIndex .. "\t"
  end
  strIndex2 = strIndex .."\t"

  local x = 0
  if type(tbl) == "table" then
    strReturn = strReturn .. strIndex .. "{\n"

       for k,v in pairs(tbl) do
      x = x + 1
      if type(k) == "number" then
        if type(v) == "table" then
          if x ==1 then
            --strReturn = strReturn .. strIndex2
          else
            --strReturn = strReturn .. ",\n" .. strIndex2
            strReturn = strReturn .. ",\n"
          end
        else
          if x ==1 then
            strReturn = strReturn .. strIndex2
          else
            strReturn = strReturn .. ",\n" .. strIndex2
          end
        end
      else
        if x ==1 then
          strReturn = strReturn .. strIndex2 .. k .. " = "
        else
          strReturn = strReturn .. ",\n" .. strIndex2 .. k .. " = "
        end
        if type(v) == "table" then
          strReturn = strReturn .. "\n"
        end
      end
      strReturn = strReturn .. commonFunctions:convertTableToString(v, i+1)
       end
     strReturn = strReturn .. "\n"
     strReturn = strReturn .. strIndex .. "}"
   else
    if type(tbl) == "number" then
      strReturn = strReturn .. tbl
    elseif type(tbl) == "boolean" then
      strReturn = strReturn .. tostring(tbl)
    elseif type(tbl) == "string" then
      strReturn = strReturn .."\"".. tbl .."\""
    end
   end
   return strReturn
 end


--Print table to ATF log. It is used to debug script.
function commonFunctions:printTable(tbl)
  print ("-------------------------------------------------------------------")
  print (commonFunctions:convertTableToString (tbl, 1))
  print ("-------------------------------------------------------------------")
end
 --------------------------------------------------

--Create new table and copy value from other tables. It is used to void unexpected change original table.
function commonFunctions:cloneTable(original)
  if original == nil then
    return {}
  end

    local copy = {}
    for k, v in pairs(original) do
        if type(v) == 'table' then
            v = commonFunctions:cloneTable(v)
        end
        copy[k] = v
    end
    return copy
end

-- Get table size on top level
local function TableSize(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

--Compare 2 tables
function commonFunctions:is_table_equal(table1, table2)
  -- compare value types
  local type1 = type(table1)
  local type2 = type(table2)
  if type1 ~= type2 then return false end
  if type1 ~= 'table' and type2 ~= 'table' then return table1 == table2 end
  local size_tab1 = TableSize(table1)
  local size_tab2 = TableSize(table2)
  if size_tab1 ~= size_tab2 then return false end

  --compare arrays
  if json.isArray(table1) and json.isArray(table2) then
    local found_element
    local copy_table2 = commonFunctions:cloneTable(table2)
    for i, _  in pairs(table1) do
      found_element = false
      for j, _ in pairs(copy_table2) do
        if commonFunctions:is_table_equal(table1[i], copy_table2[j]) then
          copy_table2[j] = nil
          found_element = true
          break
        end
      end
      if found_element == false then
        break
      end
    end
    if TableSize(copy_table2) == 0 then
      return true
    else
      return false
    end
  end

  -- compare tables by elements
  local already_compared = {} --optimization
  for _,v1 in pairs(table1) do
    for k2,v2 in pairs(table2) do
      if not already_compared[k2] and commonFunctions:is_table_equal(v1,v2) then
        already_compared[k2] = true
      end
    end
  end
  if size_tab2 ~= TableSize(already_compared) then
    return false
  end
  return true
end
---------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------
--3. Functions for Test Case
  --Note: Use global variable to add prefix and subfix to test case name:
    --TestCaseNameSuffix
    --TestCaseNamePrefix
---------------------------------------------------------------------------------------------

--Set value for a parameter on the request
function commonFunctions:setValueForParameter(Request, Parameter, Value)

  local temp = Request
  for i = 1, #Parameter - 1 do
    temp = temp[Parameter[i]]
  end

  temp[Parameter[#Parameter]] = Value

-- Due to Lua specific empty array defines as empty structure (APPLINK-15292). For testing addressLines in GetWayPoints (CRQ APPLINK-21610) response use next condition.
  if  Value == nil and Parameter[#Parameter-1] == "addressLines" then 
print("Check success response in SDL logs. Due to APPLINK-15292 ATF fails next case")

    temp[Parameter[#Parameter]] = json.EMPTY_ARRAY 
  end

  --[=[print request if parameter matches Debug value
  if Debug ~= {} then
    if #Debug == #Parameter then
      local blnPrint = true

      for i =1, #Debug do
        if Debug[i] ~= Parameter[i] then
          blnPrint = false
          break
        end
      end

      if blnPrint == true then
        commonFunctions:printTable(Request)
      end
    end
  end ]=]
end


--Global variable TestCaseNameSuffix is suffix for test case. It is used to add text at the end of test case.
local function BuildTestCase(Parameter, verificationName, resultCode)

  local testCaseName = ""
  --Add parameters to test case name
  for i = 1, #Parameter  do
    if Parameter[i] == 1 then
      testCaseName =  testCaseName .. "_" .. "element"
    else
      testCaseName =  testCaseName .. "_" .. tostring(Parameter[i])
    end
  end

  --Add verification to test case
  testCaseName = testCaseName .. "_" .. verificationName

  --Add resultCode to test case name
  if resultCode ~= nil then
    testCaseName = testCaseName .. "_" .. resultCode
  end

  --Add suffix to test case name
  if TestCaseNameSuffix ~= nil then
    testCaseName = testCaseName .. "_" .. TestCaseNameSuffix
  end

  --Add Prefix to test case name
  if TestCaseNamePrefix ~= nil then
    testCaseName = "_" .. TestCaseNamePrefix .. testCaseName
  end

  return testCaseName
end

--Build test case name from APIName, parameter and verification name
function commonFunctions:BuildTestCaseName(Parameter, verificationName, resultCode)

  return APIName .. BuildTestCase(Parameter, verificationName, resultCode)
end

--Build test case name from APIName, parameter and verification name
function commonFunctions:BuildTestCaseNameForResponse(Parameter, verificationName, resultCode)

  return APIName .. "_Response".. BuildTestCase(Parameter, verificationName, resultCode)
end


--Print new line to separate new test cases group
function commonFunctions:newTestCasesGroup(ParameterOrMessage)

  NewTestSuiteNumber = NewTestSuiteNumber + 1

  local message = ""

  --Print new lines to separate test cases group in test report
  if ParameterOrMessage == nil then
    message = "Test Suite For Parameter:"
  elseif type(ParameterOrMessage)=="table" then
    local Prameter = ParameterOrMessage

        for i = 1, #Prameter  do
      if type(Prameter[i]) == "number" then
        message =  message .. "[" .. tostring(Prameter[i]) .. "]"
      else
        if message == "" then
          message = tostring(Prameter[i])
        else
          local len  = string.len(message)
          if string.sub(message, len -1, len) == "]" then
            message =  message .. tostring(Prameter[i])
          else
            message =  message .. "." .. tostring(Prameter[i])
          end


        end
      end
    end
    message =  "Test Suite For Parameter: " .. message

  else
    message = ParameterOrMessage
    end

  Test["Suite_" .. tostring(NewTestSuiteNumber)] = function(self)

    local  length = 80
    local spaces = length - string.len(message)
    --local line1 = string.rep(" ", math.floor(spaces/2)) .. message
    local line1 = message
    local line2 = string.rep("-", length)

    print("\27[33m" .. line2 .. "\27[0m")
    print("")
    print("")
    print("\27[33m" .. line1 .. "\27[0m")
    print("\27[33m" .. line2 .. "\27[0m")

  end


end

local messageflag = false
--This function sends a request from mobile with INVALID_DATA and verify result on mobile.
function commonFunctions:verify_Unsuccess_Case(self, Request, ResultCode)

  if messageflag == false then
    print (" \27[33m verify_INVALID_DATA_Case function is absent in script for invalid cases is used common function commonFunctions:verify_Unsuccess_Case. Please add function for processing invalid cases in script. \27[0m")
  end

  --mobile side: sending the request
  local cid = self.mobileSession:SendRPC(APIName, Request)


  --mobile side: expect the response
  EXPECT_RESPONSE(cid, { success = false, resultCode = ResultCode })
  :Timeout(50)

  messageflag = true
end

--Send a request and check result code
function commonFunctions:SendRequestAndCheckResultCode(self, Request, ResultCode)

  if ResultCode == "SUCCESS" then

    self:verify_SUCCESS_Case(Request)

  elseif ResultCode == "INVALID_DATA" or ResultCode == "DISALLOWED" then

    if self.verify_INVALID_DATA_Case then
      self:verify_INVALID_DATA_Case(Request)
    else
      commonFunctions:verify_Unsuccess_Case(self, Request, ResultCode)
    end

  else

    print("Error: Input resultCode is not SUCCESS or INVALID_DATA or DISALLOWED")
  end

end

function commonFunctions:BuildChildParameter(ParentParameter, childParameter)
  local temp = commonFunctions:cloneTable(ParentParameter)
  table.insert(temp, childParameter)
  return temp
end




--Common test case
function commonFunctions:TestCase(self, Request, Parameter, Verification, Value, ResultCode)

  Test[commonFunctions:BuildTestCaseName(Parameter, Verification, ResultCode)] = function(self)

    --Copy request
    local TestingRequest = commonFunctions:cloneTable(Request)

    --Set value for the Parameter in request
    commonFunctions:setValueForParameter(TestingRequest, Parameter, Value)

    --Send the request and check resultCode
    commonFunctions:SendRequestAndCheckResultCode(self, TestingRequest, ResultCode)
  end
end



---------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------
--4. Functions for TTSChunk
---------------------------------------------------------------------------------------------

function commonFunctions:createTTSChunk(strText, strType)

  return  {
        text =strText,
        type = strType
      }

end


function commonFunctions:createTTSChunks(strText, strType, number)

  local temp = {}
  local TTSChunk = {}

  if number ==1 then
    TTSChunk = commonFunctions:createTTSChunk(strText, strType)
    table.insert(temp, TTSChunk)
  else
    for i = 1, number do
      TTSChunk = commonFunctions:createTTSChunk(strText .. tostring(i), strType)
      table.insert(temp, TTSChunk)
    end
  end

  return temp

end


---------------------------------------------------------------------------------------------
--5. Functions for SoftButton
---------------------------------------------------------------------------------------------


function commonFunctions:createSoftButton(SoftButtonID, Text, SystemAction, Type, IsHighlighted, ImageType, ImageValue)

  return
  {
    softButtonID = SoftButtonID,
    text = Text,
    systemAction = SystemAction,
    type = Type,
    isHighlighted = IsHighlighted,
    image =
    {
       imageType = ImageType,
       value = ImageValue
    }
  }
end



function commonFunctions:createSoftButtons(SoftButtonID, Text, SystemAction, Type, IsHighlighted, ImageType, ImageValue, number)

  local temp = {}
  local button = {}
  if number == 1 then
    button  = commonFunctions:createSoftButton(SoftButtonID, Text, SystemAction, Type, IsHighlighted, ImageType, ImageValue)
    table.insert(temp, button)
  else
    for i = 1, number do
      button  = commonFunctions:createSoftButton(SoftButtonID + i - 1, Text .. tostring(i), SystemAction, Type, IsHighlighted, ImageType, ImageValue)
      table.insert(temp, button)
    end
  end

  return temp

end

---------------------------------------------------------------------------------------------
--6. Functions for printing error
---------------------------------------------------------------------------------------------
function commonFunctions:printError(errorMessage)
  print()
  print(" \27[31m " .. errorMessage .. " \27[0m ")
end


function commonFunctions:sendRequest(self, Request, functionName, FunctionId)

  local message = json.encode(Request)
  local cid

  if string.find(message, "{}") ~= nil or string.find(message, "{{}}") ~= nil then
    message = string.gsub(message, "{}", "[]")
    message = string.gsub(message, "{{}}", "[{}]")

    self.mobileSession.correlationId = self.mobileSession.correlationId + 1

    local msg =
    {
      serviceType      = 7,
      frameInfo        = 0,
      rpcType          = 0,
      rpcFunctionId    = FunctionId,
      rpcCorrelationId = self.mobileSession.correlationId,
      payload          = message
    }
    self.mobileSession:Send(msg)
    cid = self.mobileSession.correlationId
  else
    --mobile side: sending the request
    cid = self.mobileSession:SendRPC(functionName, Request)
  end

  return cid
end


---------------------------------------------------------------------------------------------
--7. Functions for Response
---------------------------------------------------------------------------------------------


--Send a request and response and check result code
function commonFunctions:SendRequestAndResponseThenCheckResultCodeForResponse(self, Response, ResultCode)

  if ResultCode == "SUCCESS" then

    self:verify_SUCCESS_Response_Case(Response)

  elseif ResultCode == "GENERIC_ERROR" then

    self:verify_GENERIC_ERROR_Response_Case(Response)

  else

    print("Error: SendRequestAndResponseThenCheckResultCodeForResponse function: Input resultCode is not SUCCESS or GENERIC_ERROR")
  end

end



function commonFunctions:TestCaseForResponse(self, Response, Parameter, Verification, Value, ResultCode)

  Test[commonFunctions:BuildTestCaseNameForResponse(Parameter, Verification, ResultCode)] = function(self)

    --Copy Response
    local TestingResponse = commonFunctions:cloneTable(Response)

    --Set value for the Parameter in Response
    commonFunctions:setValueForParameter(TestingResponse, Parameter, Value)

    --Send the request and response then check resultCode
    commonFunctions:SendRequestAndResponseThenCheckResultCodeForResponse(self, TestingResponse, ResultCode)
  end
end


---------------------------------------------------------------------------------------------
--8. Functions for Notification
---------------------------------------------------------------------------------------------
--Build test case name from APIName, parameter and verification name
function commonFunctions:BuildTestCaseNameForNotification(Parameter, verificationName, resultCode)

  --return APIName .. "_Notification".. BuildTestCase(Parameter, verificationName, resultCode)
  return APIName .. BuildTestCase(Parameter, verificationName, resultCode)
end



--Send Notification and check Notification on mobile
function commonFunctions:SendNotificationAndCheckResultOnMobile(self, Notification, IsValidValue)

  if IsValidValue == true then

    self:verify_SUCCESS_Notification_Case(Notification)

  else

    self:verify_Notification_IsIgnored_Case(Notification)

  end

end


function commonFunctions:TestCaseForNotification(self, Notification, Parameter, Verification, Value, IsValidValue)

  Test[commonFunctions:BuildTestCaseNameForNotification(Parameter, Verification)] = function(self)

    --Copy BuildTestCase
    local TestingNotification = commonFunctions:cloneTable(Notification)

    --Set value for the Parameter in Notification
    commonFunctions:setValueForParameter(TestingNotification, Parameter, Value)

    --Send Notification and check Notification on mobile
    commonFunctions:SendNotificationAndCheckResultOnMobile(self, TestingNotification, IsValidValue)
  end
end

---------------------------------------------------------------------------------------------
--9. Functions for checking the existence
---------------------------------------------------------------------------------------------

-- Check directory existence
function commonFunctions:Directory_exist(DirectoryPath)
  local returnValue

  local Command = assert( io.popen(  "[ -d " .. tostring(DirectoryPath) .. " ] && echo \"Exist\" || echo \"NotExist\"" , 'r'))
  local CommandResult = tostring(Command:read( '*l' ))

  if
    CommandResult == "NotExist" then
      returnValue = false
  elseif
    CommandResult == "Exist" then
    returnValue =  true
  else
    commonFunctions:userPrint(31," Some unexpected result in Directory_exist function, CommandResult = " .. tostring(CommandResult))
    returnValue = false
  end

  return returnValue
end

-- Check file existence
function commonFunctions:File_exists(file_name) 
    local file_found=io.open(file_name, "r")  
    if file_found==nil then
      return false
    else
      return true
    end
end
---------------------------------------------------------------------------------------------
--10. Functions for updated .ini file
---------------------------------------------------------------------------------------------
-- !!! Do not update fucntion without necessity. In case of updating check all scripts where function is used.
function commonFunctions:SetValuesInIniFile(FindExpression, parameterName, ValueToUpdate )
  local SDLini = config.pathToSDL .. "smartDeviceLink.ini"

  f = assert(io.open(SDLini, "r"))
    if f then
      fileContent = f:read("*all")

      fileContentFind = fileContent:match(FindExpression)

      local StringToReplace

      if ValueToUpdate == ";" then
        StringToReplace =  ";" .. tostring(parameterName).. " =  \n"
      else
        StringToReplace =  tostring(parameterName) .. " = " .. tostring(ValueToUpdate) .. "\n"
      end

      if fileContentFind then
        fileContentUpdated  =  string.gsub(fileContent, FindExpression, StringToReplace)

        f = assert(io.open(SDLini, "w"))
        f:write(fileContentUpdated)
      else
        commonFunctions:userPrint(31, "Finding of '" .. tostring(parameterName) .. " = value' is failed. Expect string finding and replacing the value to " .. tostring(ValueToUpdate))
      end
      f:close()
    end
end

---------------------------------------------------------------------------------------------
--11. Function for updating PendingRequestsAmount in .ini file to test TOO_MANY_PENDING_REQUESTS resultCode
---------------------------------------------------------------------------------------------
function commonFunctions:SetValuesInIniFile_PendingRequestsAmount(ValueToUpdate)
  commonFunctions:SetValuesInIniFile("%p?PendingRequestsAmount%s?=%s-[%d]-%s-\n", "PendingRequestsAmount", ValueToUpdate)
end
---------------------------------------------------------------------------------------------
--12. Functions array of structures
---------------------------------------------------------------------------------------------
function commonFunctions:createArrayStruct(size, Struct)

  if length == nil then
    length = 1
  end

  local temp = {}
  for i = 1, size do
    table.insert(temp, Struct)
  end

  return temp

end
---------------------------------------------------------------------------------------------
--13. Functions for SDL stop
---------------------------------------------------------------------------------------------
function commonFunctions:SDLForceStop(self)
  os.execute("ps aux | grep smart | awk \'{print $2}\' | xargs kill -9")
  sleep(1)
end

function sleep(n)
  os.execute("sleep " .. tonumber(n))
end

function check_file_existing(path)
  local file = io.open(path, "r")
  if file == nil then
    print("File doesnt exist, path:"..path)
    assert(false)
  else
    local ok, err, code = file:read(1)
    if code == 21 then
      print("It is path to directory")
      file:close()
      assert(false)
    end
  end
  file:close()
end

function concatenation_path(path1, path2)
  local len = string.len(path1)
  if string.sub(path1, len, len) == '/' then
    return path1..path2
  end
  return path1..'/'..path2 
end

---------------------------------------------------------------------------------------------
--14. Function gets parameter from smartDeviceLink.ini file
---------------------------------------------------------------------------------------------
function commonFunctions:read_parameter_from_smart_device_link_ini(param_name)
  local path_to_ini_file = concatenation_path(config.pathToSDL, "smartDeviceLink.ini")
  check_file_existing(path_to_ini_file)
  local param_value  = nil
  for line in io.lines(path_to_ini_file) do
    if string.match(line, "^%s*"..param_name.."%s*=%s*") ~= nil then
      if string.find(line, "%s*=%s*$") ~= nil then
        param_value = ""
        break
      end
      local b, e = string.find(line, "%s*=%s*.")
      if b ~= nil then
        local len = string.len(line)
        param_value = string.sub(line, e, len)
        break
      end
    end
  end
  return param_value
end

---------------------------------------------------------------------------------------------
--15. Function sets parameter to smartDeviceLink.ini file
---------------------------------------------------------------------------------------------
function commonFunctions:write_parameter_to_smart_device_link_ini(param_name, param_value)
  local path_to_ini_file = concatenation_path(config.pathToSDL, "smartDeviceLink.ini")
  check_file_existing(path_to_ini_file)
  local new_file_content = ""
  local is_find_string = false
  local result = false
  for line in io.lines(path_to_ini_file) do
    if is_find_string == false then
      if string.match(line, "^%s*"..param_name.."%s*=%s*") ~= nil then
        line = param_name.." = "..param_value
        is_find_string = true
      end
    end
    new_file_content = new_file_content..line.."\n"
  end
  if is_find_string == true then
    local file = io.open(path_to_ini_file, "w")
    if file then
      file:write(new_file_content)
      file:close()
      result = true
    else
      print("File doesn't open, path:"..path_to_ini_file)
      assert(false)
    end
  end
  return result
end

---------------------------------------------------------------------------------------------
--16. Function transform data from PTU to permission change data
---------------------------------------------------------------------------------------------
function commonFunctions:convert_ptu_to_permissions_change_data(path_to_ptu, group_name, is_user_allowed)
  local permission_item_json_template = [[{"rpcName":"",
  "parameterPermissions":{"userDisallowed":[], "allowed":[]},
  "hmiPermissions":{"allowed":[], "userDisallowed":[]}}]]
  local permission_item_table_template = json.decode(permission_item_json_template);
  local file = io.open(path_to_ptu, "r")
  if file == nil then
    print("File doesnt exist, path:"..path_to_ptu)
    assert(false)
  end

  local json_data = file:read("*a")
  file:close()

  local data = json.decode(json_data)
  local rpcs = nil
  for key in pairs(data.policy_table.functional_groupings) do
    if key == group_name then
      rpcs = data.policy_table.functional_groupings[key].rpcs
      break
    end
  end
  local permission_items = {}
  local permission_item
  if rpcs == nil then
    print("Group name:"..group_name.." doesn't contain list of rpcs")
    assert(false)
  end

  for key in pairs(rpcs) do
    permission_item = commonFunctions:cloneTable(permission_item_table_template)
    permission_item.rpcName = key
    if is_user_allowed == true then
      permission_item.hmiPermissions.allowed = rpcs[key].hmi_levels
    else
      permission_item.hmiPermissions.userDisallowed = rpcs[key].hmi_levels
    end
    table.insert(permission_items, permission_item)
  end
  return permission_items
end

---------------------------------------------------------------------------------------------
-- Function returns output from console
---------------------------------------------------------------------------------------------
function os.capture(cmd, raw)
   local f = assert(io.popen(cmd, 'r'))
     local s = assert(f:read('*a'))
   f:close()
   if raw then return s end
   s = string.gsub(s, '^%s+', '')
   s = string.gsub(s, '%s+$', '')
   s = string.gsub(s, '[\n\r]+', ' ')
   return s
 end

---------------------------------------------------------------------------------------------
--17. Function returns data from sqlite by query
---------------------------------------------------------------------------------------------
--! @brief Gets data from db
--! @param db_path path to DB
--! @param sql_query contains select query with determine name of column. Don't use query with *
--! @return array with value from column
function commonFunctions:get_data_policy_sql(db_path, sql_query)
  if string.match(sql_query, "^%a+%s*%*%s*%a+") ~= nil then
    print("Please specife name of column, don't use *")
    assert(false)
  end
  check_file_existing(db_path)
  local commandToExecute = "sqlite3 "..db_path .." \""..sql_query.."\""
  local db = nil
  local time_to_wait_read_data = 1
  local attempts_to_read = 10
  local selected_data = ""
  for i = 1, attempts_to_read do
    sleep(time_to_wait_read_data)
    db = assert(io.popen(commandToExecute, 'r'))
    selected_data = assert(db:read('*a'))
    db:close()
    if string.len(selected_data) ~= 0 then
      break
    end
  end

  local column_db = {}
  if string.len(selected_data) == 0 then
    print("WARNING: script can not take data from DB. Please check query")
  else
    local b, e = 1, 0
    while e < string.len(selected_data) do
      e = string.find(selected_data, "\n", b)
      table.insert(column_db, string.sub(selected_data, b, e-1))
      b = e+1
    end
  end
  return column_db
end

---------------------------------------------------------------------------------------------
--18. Function checks value of column from DB with input data
---------------------------------------------------------------------------------------------
--! @brief Check if DB contains column with data
--! @param db_path path to DB
--! @param sql_query contains select query with determine name of column. Don't use query with *
--! @param exp_result contains data for comparing data from DB
--! @return Returns false if expected data are not equal with DB data, otherwise returns true.
function commonFunctions:is_db_contains(db_path, sql_query, exp_result)
  local column_db = commonFunctions:get_data_policy_sql(db_path, sql_query)
  return commonFunctions:is_table_equal(column_db, exp_result)
end

return commonFunctions