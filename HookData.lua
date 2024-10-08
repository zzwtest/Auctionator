
---@type ns
local ns = select(2, ...)




ns.HookAu = {}
ns.HookAu.auDoItemsing = false
ns.HookAu.auOpend = false
ns.HookAu.hasError = false

local factionGroup = UnitFactionGroup("player")
print(factionGroup,factionGroup == "Alliance")
-- 部落搜索
local auHordeSearchItems ={
    -- 物品名, 单价(gold), 最小数量,最大数量

--    {"永恒之水",1.45,1,20},
    --{"无限之尘",1.1,1,20},
   -- {"奥法之尘",1,1,20},
    --{"金矿石",0.95,1,20},
    {"魔铁锭",8.5,1,20},
    {"魔铁矿石",4,1,20},
    {"冰霜巨龙合剂",8.2,1,20},

   --{"奥杜尔的圣物",0.048,1,200},

}
-- 联盟搜索
local auAllianceSearchItems ={
    -- 物品名, 单价(gold), 最小数量,最大数量
    {"青铜锭",0.99,1,20},
    {"铜矿石",0.38,1,20},
    {"锡矿石",1.1,1,20},
    {"秘银矿石",3.1,1,20},
    {"秘银锭",3.1,1,20},
    {"魔纹布",0.2,1,20},

    {"铁矿石",1.2,1,20},
    {"铁锭",1.2,1,20},

    {"铜锭",0.35,1,20},
    --{"亚麻布",0.065,1,20},
    --{"毛料",0.20,1,20},
    --{"丝绸",0.05,1,20},

    {"沉重的石头",0.6,1,20},
    -- {"银矿石",5,1,20},

    -- {"萨隆邪铁矿石",0.7,1,20},
    -- {"北地皮",0.35,1,20},
    -- {"精金矿石",0.40,1,20},

    

}
if factionGroup == "Horde" then
    ns.HookAu.auSearchItems = auHordeSearchItems
else 
    ns.HookAu.auSearchItems = auAllianceSearchItems
end


-- 诱导捡漏 购买的时候 剔除掉自己 
local auYDItems ={
    
    { "小型亚口鱼",  -- 物品名 
      0.34, --  低单价 
      20 , -- 低单价诱导数量  
      0.48,-- 收购价
      0.7, -- 收购低于 收购价的 70%的 物品 ，留 30% 种子  
    },

}
ns.HookAu.auYDItems = auYDItems


-- 联盟 出售
local auSellItemsHorde ={
    -- 物品名, 单价(gold), 最大单价 ,单组最大数量，首页我占有最小数量 , 检查数量 前X个 
   -- {"护甲羊皮纸 III",2.88 , 3.5  , 4,3},
    --  {"奥法之尘",1.9,   5  ,  8, 3},
     --{"奥杜尔的圣物",0.06 , 0.12  , 10,3},
   --  {"劣质的石头", 0.12, 1, 20  , 2,4 }, 
    {"秘银锭", 3.6, 4.9, 8  , 2,6 },
    --{"青铜锭",1.49, 2, 12  , 2,4},

    -- {"青铜锭", 1.5, 2.2, 12  , 2,6 },
}

-- 部落 出售
local auSellItemsAlliance ={
    -- 物品名, 单价(gold), 最大单价 ,单组最大数量，首页我占有最小数量 , 检查数量 前X个 
    -- {"实心炸药",0.6,   2  ,  5, 3},
    --  {"食谱：烟熏鲈鱼",4, 11, 1  , 2},
  --   {"沉重的石头",1.24, 5,10  , 3},
--    {"源生生命", 7, 11, 1  , 1,2},
--    {"图样：灵纹外套",16, 25,1  , 1,2},
--    {"巫妖花",3.3, 5, 12 , 2,6},
    --  {"毛料",0.59,   2  ,  10, 3},
    -- {"青铜锭",0.88, 5,20  , 30},
   -- {"食谱：刺须鲶鱼", 1.2, 9, 1  , 1,4 }, 
    --{"青铜锭",1.49, 2, 12  , 2,4},
    --  {"铜锭",0.9, 3,10  , 3},     
    {"坚固的石头", 0.4, 3, 16  , 2,4 }, 
    {"丝绸", 0.3, 3, 20  , 2,4 }, 

    -- {"奥杜尔的圣物",0.25 , 0.48  , 40,3},
}

ns.HookAu.auSellItemsRegex = {
   {"^食谱",2, 12, 1  , 1,2},
} 


if factionGroup == "Horde" then
    ns.HookAu.auSellItems = auSellItemsAlliance
else 
    ns.HookAu.auSellItems = auSellItemsHorde
end



local auSearchJLItems ={}


auSearchJLItems["附魔披风 - 超强敏捷"] = 11
auSearchJLItems["附魔靴子 - 强效精神"] = 11
auSearchJLItems["附魔盾牌 - 躲闪"] = 11
auSearchJLItems["附魔护腕 - 特效耐力"] = 11 
auSearchJLItems["附魔法杖 - 法术能量"] = 11
auSearchJLItems["附魔胸甲 - 优异韧性"] = 11
auSearchJLItems["附魔护腕 - 强效法术能量"] = 11 
auSearchJLItems["附魔护腕 - 强效法术能量"] = 11

auSearchJLItems["闪光魔线"] = 5


auSearchJLItems["丝绸"] = 0.07
auSearchJLItems["毛料"] = 0.2
auSearchJLItems["亚麻布"] = 0.07
auSearchJLItems["金苜蓿"] = 0.2

auSearchJLItems["梦叶草"] = 0.2
auSearchJLItems["巫妖花"] = 2.6
auSearchJLItems["蛇信草"] = 0.9
auSearchJLItems["冰棘草"] = 0.9
auSearchJLItems["卷丹"] = 0.35

auSearchJLItems["无限之尘"] = 1
auSearchJLItems["奥法之尘"] = 0.78


auSearchJLItems["魔化之泪"] = 100
auSearchJLItems["幻象之尘"] = 0.2

auSearchJLItems["新鲜的刺须鲶鱼"] = 0.2
-- auSearchJLItems["水母"] = 0.2
-- auSearchJLItems["冰河鲑鱼"] = 0.6
-- auSearchJLItems["北风水母"] =0.6
-- auSearchJLItems["铲齿鹿肋排"] = 0.6
-- auSearchJLItems["蚌肉"] = 0.6
-- auSearchJLItems["猛犸肉"] =0.2
-- auSearchJLItems["北地香料"] =1
-- auSearchJLItems["蚌肉"] = 0.6
-- auSearchJLItems["龙鳞天使鱼"] = 0.6
-- auSearchJLItems["小型亚口鱼"] = 0.1
auSearchJLItems["香辣猛犸小吃"] = 1
auSearchJLItems["结构图：白色烟幕弹"] = 10


--auSearchJLItems["土之微粒"] = 0.23
auSearchJLItems["生命微粒"] = 0.1
auSearchJLItems["火焰微粒"] = 1

auSearchJLItems["源生之土"] = 1
auSearchJLItems["欺诈宝珠"] =0.6
auSearchJLItems["源生之土"] = 1
auSearchJLItems["艾泽拉斯钻石"] =2 

auSearchJLItems["秘银锭"] = 3
auSearchJLItems["秘银矿石"] = 3
auSearchJLItems["银锭"] = 3.4
auSearchJLItems["瑟银矿石"] = 0.5
auSearchJLItems["瑟银锭"] = 0.6
auSearchJLItems["青铜锭"] =0.9
auSearchJLItems["精金锭"] =1.4
auSearchJLItems["精金矿石"] =0.65

auSearchJLItems["大猫眼石"] = 1.2

auSearchJLItems["铁锭"] = 1.1
auSearchJLItems["铁矿石"] = 1
auSearchJLItems["锡矿石"] = 0.7
auSearchJLItems["锡锭"] = 0.75
auSearchJLItems["次级月亮石"] =1.2
auSearchJLItems["铜矿石"] = 0.4
auSearchJLItems["铜锭"] = 0.45

auSearchJLItems["金矿石"] = 0.4
auSearchJLItems["沉重的石头"] = 0.6
auSearchJLItems["萨隆邪铁矿石"] = 0.66
auSearchJLItems["银矿石"] = 3
auSearchJLItems["坚固的石头"] = 0.1
auSearchJLItems["魔铁矿石"] = 3
auSearchJLItems["魔铁锭"] = 6.0



print(GetZoneText(), GetSubZoneText())
if GetSubZoneText() == "藏宝海湾" then 

    auSearchJLItems["永恒生命"] = 10
    -- auSearchJLItems["永恒暗影"] = 0.6
    auSearchJLItems["永恒之水"] = 1
    auSearchJLItems["永恒之土"] = 1    

    auSearchJLItems["血玉石"] = 10
    auSearchJLItems["龙眼石"] = 10
    auSearchJLItems["暗月卡片：幻象"] = 10
    auSearchJLItems["暗月卡片：死亡"] = 10
    auSearchJLItems["暗月卡片：狂暴！"] = 10
    auSearchJLItems["暗月卡片：伟大"] = 100
    auSearchJLItems["永恒腰带扣"] = 2
    auSearchJLItems["冰冻宝珠"] = 2
    auSearchJLItems["深渊水晶"] = 2
    auSearchJLItems["法纹布"] = 100
    auSearchJLItems["食谱：美味风蛇"] = 30
    auSearchJLItems["冰霜巨龙合剂"] = 7.5
    auSearchJLItems["无尽怒气合剂"] = 6

    auSearchJLItems["月影布"] = 1
    auSearchJLItems["速度药水"] = 2.5
    auSearchJLItems["狂野魔法药水"] = 2.5
    auSearchJLItems["乌纹布"] =1
    auSearchJLItems["海妖之泪"] = 1

    auSearchJLItems["钢铁议会披风"] =1 
    auSearchJLItems["秘银矿石"] = 1
    auSearchJLItems["冰鳞腿甲片"] = 1
    auSearchJLItems["霜皮腿甲片"] = 1

    auSearchJLItems["泰坦神铁锭"] = 0.6
    auSearchJLItems["暗月卡片：狂暴！"] = 1
    auSearchJLItems["强效宇宙精华"] = 0.2
end 
-- auSearchJLItems["新鲜的滑皮鲭鱼"] = 0.0347
-- auSearchJLItems["煤块"] = 0.04


ns.HookAu.auSearchJLItems = auSearchJLItems









local function calculateSalePrice(prices)
    local sum = 0
    for _, price in ipairs(prices) do
        sum = sum + price
    end
    local meanPrice = sum / #prices

    -- 计算标准差
    local sumSquaredDifferences = 0
    for _, price in ipairs(prices) do
        sumSquaredDifferences = sumSquaredDifferences + (price - meanPrice)^2
    end
    local stdDev = math.sqrt(sumSquaredDifferences / #prices)

    -- 定义波动大的阈值为平均价的20%
    local threshold = 0.2 * meanPrice
    
    table.sort(prices)
    return prices[1] - 0.0001



    -- if stdDev < threshold then
    --     -- 波动不大，按最低价减0.1售卖
    --     table.sort(prices)
    --     return prices[1] - 0.0001
    -- else
    --     -- 波动很大，剔除较低的价格
    --     local cutOff = meanPrice * 0.8  -- 定义剔除低于平均价20%的价格
    --     local filteredPrices = {}
    --     for _, price in ipairs(prices) do
    --         if price > cutOff then
    --             table.insert(filteredPrices, price)
    --         end
    --     end
    --     if #filteredPrices == 0 then -- 如果过滤后没有商品，返回原最低价减0.1
    --         table.sort(prices)
    --         return prices[1] - 0.1
    --     else
    --         table.sort(filteredPrices)
    --         return filteredPrices[1] - 0.1
    --     end
    -- end
end
ns.HookAu.calculateSalePrice = calculateSalePrice


-- 定义日志级别
local LOG_LEVEL = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4,
}

-- 定义日志级别对应的颜色
local LOG_COLOR = {
    [LOG_LEVEL.DEBUG] = "|cFF9D9D9D", -- 灰色
    [LOG_LEVEL.INFO] = "|cFF00FF00", -- 绿色
    [LOG_LEVEL.WARN] = "|cFFFFFF00", -- 黄色
    [LOG_LEVEL.ERROR] = "|cFFFF0000", -- 红色
}

-- 当前日志级别
local currentLogLevel = LOG_LEVEL.DEBUG

-- 获取当前时间的字符串表示
local function GetTimeString()
    local time = date("*t") -- 获取当前时间的table
    return string.format("%02d:%02d:%02d", time.hour, time.min, time.sec)
end
-- 保留之前的定义（LOG_LEVEL, LOG_COLOR, currentLogLevel, GetTimeString）

-- 修改后的日志打印函数，支持多参数
local function LogPrint(level, ...)
    -- 如果当前日志级别小于或等于设置的日志级别，则输出日志
    if level >= currentLogLevel then
        -- 获取日志颜色
        local color = LOG_COLOR[level] or "|cFFFFFFFF" -- 默认白色
        -- 获取时间字符串
        local timeString = GetTimeString()
        -- 处理多参数，将所有参数转换为字符串并连接
        local messageParts = {...} -- 将所有参数放入表中
        for i=1, #messageParts do
            messageParts[i] = tostring(messageParts[i]) -- 确保所有部分都是字符串
        end
        local message = table.concat(messageParts, " ") -- 使用空格连接所有部分
        -- 构造最终的日志字符串
        local logMessage = string.format("%s%s [%s] %s|r", color, timeString, level, message)
        -- 使用默认的聊天窗口输出日志
        DEFAULT_CHAT_FRAME:AddMessage(logMessage)
    end
end

-- 修改后的方便使用的日志函数，以支持多参数
local function LogDebug(...)
    LogPrint(LOG_LEVEL.DEBUG, ...)
end

local function LogInfo(...)
    LogPrint(LOG_LEVEL.INFO, ...)
end

local function LogWarn(...)
    LogPrint(LOG_LEVEL.WARN, ...)
end

local function LogError(...)
    LogPrint(LOG_LEVEL.ERROR, ...)
end

-- 使用示例
-- LogDebug("这是一条调试信息", "附加信息1", 123, "附加信息2")
-- LogInfo("这是一条普通信息", "附加信息", true)
-- LogWarn("这是一条警告信息", {key = "value"}, "附加信息")
-- LogError("这是一条错误信息", "附加信息1", "附加信息2")

ns.HookAu.LogInfo = LogInfo
ns.HookAu.LogDebug= LogDebug
ns.HookAu.LogWarn= LogWarn
ns.HookAu.LogError= LogError
