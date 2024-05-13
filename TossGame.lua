successText = 'Success'
failedText = "Failed"
rankList = rankList or {}
timesList = timesList or {}
members =members or {}
gameTimeTag =gameTimeTag or ""

local function guid()
    local seed = { 'e', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' }
    local tb = {}
    for i = 1, 32 do
        table.insert(tb, seed[math.random(1, 16)])
    end
    local sid = table.concat(tb)
    return string.format('%s-%s-%s-%s-%s',
        string.sub(sid, 1, 8),
        string.sub(sid, 9, 12),
        string.sub(sid, 13, 16),
        string.sub(sid, 17, 20),
        string.sub(sid, 21, 32)
    )
end

local function getCoinNumber() -- 函数定义注释用于性能，可用于调试
    local coinNumber = 0
    while (coinNumber == 0 or coinNumber == 0.7)
    do
        coinNumber = math.random()
    end
    return coinNumber
end

local function getCoinText()
    local num = getCoinNumber()
    if num < 0.7 then
        return successText
    else
        return failedText
    end
end

function printPersonNumber(id)
    print(#members)
end

local function joinStatistic(id)
    members[id]=true
end

local function getPersonCoin(id)
    return timesList[id] or 0
end
local function sortRankList()
    table.sort(rankList, function(a, b)
        return a.times > b.times
    end)
end
local function getGameTimeTag()
    return os.date("*t", os.time()).year .. '-' .. os.date("*t", os.time()).month
end

local function checkRankExpire()
    local curentTag = getGameTimeTag()
    if gameTimeTag ~= curentTag then
        for i = 1, 10 do
            if rankList[i].pid then
                ao.send({ Target = ao.id, Action = "Transfer", Recipient = rankList[i].pid, Quantity = tostring(100-(i-1)*10)})
            end
        end
        rankList = {}
        gameTimeTag = curentTag
    end
end

--Get All Rank List
Handlers.add(
    "HandlerGetCoinRank",
    Handlers.utils.hasMatchingTag("Action", "GetCoinRank"),
    function(Msg)
        if #rankList==0 then
            ao.send({
                Target = Msg.From,
                Action = "RankList",
                Data = "rankList : No Any Person"
            })
            return
        end

        checkRankExpire()
        local page = tonumber(Msg.Data)
        if (page == nil) then
            page = 1
        end
        local startPos = (page - 1) * 10 + 1
        if (startPos > #rankList) then
            startPos = 1
        end
        local endPos = startPos + 10
        local maxPos = math.min(endPos, #rankList)
        local retText = ''
        for i = startPos, maxPos do
            retText = retText .. 'Rank ' .. i .. " :    " .. rankList[i].name .."    "..rankList[i].times
            if startPos ~= maxPos then
                retText = retText .. '\n'
            end
        end
        ao.send({
            Target = Msg.From,
            Action = "RankList",
            Data = retText
        })
    end
)


-- Get Current Coin Number
Handlers.add(
    "HandlerGetCoin",
    Handlers.utils.hasMatchingTag("Action", "GetCoin"),
    function(Msg)
        local text = getPersonCoin(Msg.From)
        print(text.."Coin")
        ao.send({
            Target = Msg.From,
            Action = "CurrentCoin",
            Data = text..""
        })
    end
)

--Finish Current Coin
Handlers.add(
    "HandlerFinishCoin",
    Handlers.utils.hasMatchingTag("Action", "FinishCoin"),
    function(Msg)
        checkRankExpire()
        local uuid = guid()
        table.insert(rankList, {
            times = timesList[Msg.From],
            name = Msg.Data,
            uuid = uuid,
            pid = Msg.From
        })
        sortRankList()
        timesList[Msg.From] = 0
        local current = "Unkonw"
        for index, obj in pairs(rankList) do
            if obj.uuid == uuid then
                current = index
                break
            end
        end


        ao.send({
            Target = Msg.From,
            Action = "FinishCoinResult",
            Data = "Hey ! This Toss Coin Game You Rank is "
                ..
                current
        })
    end
)



--Toss Coin
Handlers.add(
    "HandlerCoin",
    Handlers.utils.hasMatchingTag("Action", "TossCoin"),
    function(Msg)
        local text = getCoinText()
        if (text == successText) then
            timesList[Msg.From] = getPersonCoin(Msg.From) + 1
        else
            timesList[Msg.From] = 0
        end
        joinStatistic(Msg.From)
        ao.send({
            Target = Msg.From,
            Action = "TossCoinResult",
            Data = text
        })
    end
)
