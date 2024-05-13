TossName = "LiHengDao"   -- your Name/你名
local stepNumber = 1 -- init Toss Step
local stopNumber = 9 -- stop Toss Number/最大停止的阶级次数
local runStatus = 'disable'
local currnetNumber = 0
local Toss = '_eZgREmp6W9PpIgZTpT1-7knkCFcHFKHiHZss4cNvvA'
local lock = false

local function sendToss()
    ao.send({
        Target = Toss,
        Action = "TossCoin",
    })
end

local function finishToss()
    ao.send({
        Target = Toss,
        Action = "FinishCoin",
        Data = TossName
    })
    currnetNumber = 0
end

function startToss()
    runStatus = 'enable'
    sendToss()
end

function stopToss()
    runStatus = 'disable'
    print('the bot run finnish')
end

Handlers.add(
    "HandlerTossCoinResult",
    Handlers.utils.hasMatchingTag("Action", "TossCoinResult"),
    function(Msg)
        if runStatus == 'disable' then
            return
        end
        if (Msg.Data ~= "Failed") then
            currnetNumber = currnetNumber + 1
            print('Toss Success ' .. currnetNumber)
            if (currnetNumber >= stepNumber) then
                stepNumber = stepNumber + 1
                finishToss()
            else
                sendToss()
            end
        else
            currnetNumber = 0
            print('Toss Failed')
            sendToss()
        end
    end
)

Handlers.add(
    "HandlerFinishCoinResult",
    Handlers.utils.hasMatchingTag("Action", "FinishCoinResult"),
    function(Msg)
        if runStatus == 'disable' then
            return
        end
        print(Msg.Data)
        if stopNumber < stepNumber then
            stopToss()
            return
        end
        sendToss()
    end
)

Handlers.add(
    "HandlerCurrentCoin",
    Handlers.utils.hasMatchingTag("Action", "CurrentCoin"),
    function(Msg)
        print(Msg.Data)
    end
)

Handlers.add(
    "HandlerRankList",
    Handlers.utils.hasMatchingTag("Action", "RankList"),
    function(Msg)
        print(Msg.Data)
    end
)
