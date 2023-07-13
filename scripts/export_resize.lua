-- This script take a folder, then will export every single aseprite files with the specified parameters.

local arguments = {...}

--for i,arg in ipairs(arguments) do
--    print(arg)
--end
--os.execute("cls")

if app.apiVersion < 20 then
    return app.alert("This script requires Aseprite v1.3-rc2")
end
