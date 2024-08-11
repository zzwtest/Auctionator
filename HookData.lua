
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

   {"永恒之水",1.45,1,20},
    -- {"幻象之尘",0.5,1,20},
    {"奥法之尘",0.92,1,20},
    {"奥杜尔的圣物",0.075,1,200},

}
-- 联盟搜索
local auAllianceSearchItems ={
    -- 物品名, 单价(gold), 最小数量,最大数量
    {"青铜锭",0.68,1,20},
    {"铜矿石",0.34,1,20},
    {"锡矿石",0.8,1,20},
    {"铜锭",0.34,1,20},
    {"沉重的石头",0.60,1,20},
    {"萨隆邪铁矿石",0.7,1,20},
    {"北地皮",0.35,1,20},
    {"精金矿石",0.40,1,20},

    

}
if factionGroup == "Horde" then
    ns.HookAu.auSearchItems = auHordeSearchItems
else 
    ns.HookAu.auSearchItems = auAllianceSearchItems
end

-- 联盟 出售
local auSellItemsHorde ={
    -- 物品名, 单价(gold), 最大单价 ,单组最大数量，首页我占有最小数量 
    {"奥杜尔的圣物",0.17 , 0.48  , 40,3},

}

-- 部落 出售
local auSellItemsAlliance ={
    -- 物品名, 单价(gold), 最大单价 ,单组最大数量，首页我占有最小数量 
    --  {"奥法之尘",1.31,   5  ,  10, 3},
    -- {"青铜锭",0.88, 5,20  , 30},
    -- {"青铜锭",0.88, 5,20  , 30},
    {"铜锭",0.54, 5,10  , 3},
    -- {"沉重的石头",1.24, 5,10  , 3},
 
    -- {"奥杜尔的圣物",0.25 , 0.48  , 40,3},

}

if factionGroup == "Horde" then
    ns.HookAu.auSellItems = auSellItemsAlliance
else 
    ns.HookAu.auSellItems = auSellItemsHorde
end



local auSearchJLItems ={}
auSearchJLItems["梦叶草"] = 0.1
auSearchJLItems["巫妖花"] = 0.06
auSearchJLItems["蛇信草"] = 0.06
auSearchJLItems["太阳草"] = 0.06
auSearchJLItems["雨燕草"] = 0.06

auSearchJLItems["奥法之尘"] = 0.06
auSearchJLItems["魔化之泪"] = 0.06
auSearchJLItems["幻象之尘"] = 0.06
auSearchJLItems["硬甲皮"] = 0.06


auSearchJLItems["新鲜的刺须鲶鱼"] = 0.06
auSearchJLItems["水母"] = 0.06
auSearchJLItems["冰河鲑鱼"] = 0.06
auSearchJLItems["北风水母"] = 0.06
auSearchJLItems["铲齿鹿肋排"] = 0.06
auSearchJLItems["蚌肉"] = 0.06
auSearchJLItems["猛犸肉"] = 0.06
auSearchJLItems["北地香料"] = 0.06
auSearchJLItems["蚌肉"] = 0.06
auSearchJLItems["龙鳞天使鱼"] = 0.06
auSearchJLItems["小型亚口鱼"] = 0.06



auSearchJLItems["源生之土"] = 0.06
auSearchJLItems["水之结晶"] = 0.06
auSearchJLItems["源生生命"] = 0.06
auSearchJLItems["欺诈宝珠"] = 0.06
auSearchJLItems["源生之土"] = 0.06
auSearchJLItems["艾泽拉斯钻石"] = 0.06

auSearchJLItems["铁锭"] = 0.06
auSearchJLItems["银锭"] = 0.06
auSearchJLItems["瑟银锭"] = 0.06
auSearchJLItems["青铜锭"] = 0.06
auSearchJLItems["血玉石"] = 0.06
auSearchJLItems["大猫眼石"] = 0.06
auSearchJLItems["铜锭"] = 0.06
auSearchJLItems["铁矿石"] = 0.06
auSearchJLItems["魔钢锭"] = 0.06
auSearchJLItems["锡矿石"] = 0.06
auSearchJLItems["龙眼石"] = 0.06
auSearchJLItems["次级月亮石"] = 0.06
auSearchJLItems["金矿石"] = 0.06
auSearchJLItems["铜矿石"] = 0.06
auSearchJLItems["锡锭"] = 0.06
auSearchJLItems["金矿石"] = 0.06
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

    if stdDev < threshold then
        -- 波动不大，按最低价减0.1售卖
        table.sort(prices)
        return prices[1] - 0.0001
    else
        -- 波动很大，剔除较低的价格
        local cutOff = meanPrice * 0.8  -- 定义剔除低于平均价20%的价格
        local filteredPrices = {}
        for _, price in ipairs(prices) do
            if price > cutOff then
                table.insert(filteredPrices, price)
            end
        end
        if #filteredPrices == 0 then -- 如果过滤后没有商品，返回原最低价减0.1
            table.sort(prices)
            return prices[1] - 0.1
        else
            table.sort(filteredPrices)
            return filteredPrices[1] - 0.1
        end
    end
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
