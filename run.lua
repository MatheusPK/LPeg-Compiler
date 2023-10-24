local inputFile = arg[1]
local outputFile = arg[2] or "main"

if not inputFile then
    print("Missing Input File")
    return
end

local commands = {
    string.format("cat %s | lua src/compiler.lua > temp.ll", inputFile),
    "llc temp.ll",
    string.format("clang -o %s temp.s", outputFile),
    string.format("./%s", outputFile)
}

for _, command in ipairs(commands) do
    print("running command: " .. command)
    local status = os.execute(command)
    if not status then return end
end
