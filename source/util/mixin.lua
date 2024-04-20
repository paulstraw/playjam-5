-- https://devforum.play.date/t/lua-oop-mixin-support-supplements-corelibs-object/333
function Object:implements(...)
  for _, cls in pairs({...}) do
    for k, v in pairs(cls) do
      if self[k] == nil and type(v) == "function" then
        self[k] = v
      end
    end
  end
end
