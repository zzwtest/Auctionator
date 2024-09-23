
---@type ns
local ns = select(2, ...)



print("HookAu")

-- 搜索功能对象  
-- _G["gAuctionatorShoppingSelf"]:DoSearch({"金苜蓿"})
_G["gAuctionatorShoppingSelf"] = nil



-- 购买窗口对象 
-- _G["gAuctionatorBuyDialogMixinSelf"]:BuyStackClicked()
_G["gAuctionatorBuyDialogMixinSelf"] = nil



-- https://wowpedia.fandom.com/wiki/API_QueryAuctionItems
-- QueryAuctionItems("", 1, 10, 0, nil, nil, false, false, nil)

-- Auctionator.AH.PlaceAuctionBid(self.buyInfo.index, self.auctionData.stackPrice) 

local auSearchItems = ns.HookAu.auSearchItems
local auJLLoopCount = 0 
local jlEventFrame = nil 



local auEventFrame = CreateFrame("Frame", "MyauEventFrame",UIParent)
auEventFrame:RegisterEvent("AUCTION_HOUSE_SHOW")
auEventFrame:RegisterEvent("AUCTION_HOUSE_CLOSED")
auEventFrame:RegisterEvent("UI_ERROR_MESSAGE")
auEventFrame:RegisterEvent("AUCTION_BIDDER_LIST_UPDATE")
auEventFrame:RegisterEvent("AUCTION_OWNED_LIST_UPDATE")
auEventFrame:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
--auEventFrame:RegisterEvent("AUCTION_HOUSE_AUCTION_CREATED")
auEventFrame.Signal_001_CallBack = nil 


local  function Signal_001(callback)
    auEventFrame.Signal_001_CallBack = callback
end


auEventFrame:SetFrameStrata("TOOLTIP")
auEventFrame:SetFrameLevel(128)
auEventFrame:EnableKeyboard(true)
auEventFrame:SetPropagateKeyboardInput(true);
auEventFrame.PropagateKeyboardInput = true
auEventFrame:SetScript("OnKeyDown", function(self, event, ...)
    if IsAltKeyDown() and (event == "PAGEUP" or event == "PAGEDOWN") then
        --print(IsAltKeyDown(),event)
        if event == "PAGEDOWN" then
            -- print("threeDimensionsCode","PAGEDOWN")
            if auEventFrame.Signal_001_CallBack  then 
                ns.HookAu.LogInfo("Signal_001_CallBack called ",_callback)
                local _callback = auEventFrame.Signal_001_CallBack 
                auEventFrame.Signal_001_CallBack = nil
                _callback()
            end 
            
        end
    end
end)






-- 本次最大扫货动用的最大金币，不高于余额的30%
ns.HookAu.maxGoldP = 0.3
ns.HookAu.startGold = GetMoney()/10000
local function checkGold()
    if (ns.HookAu.startGold - GetMoney()/10000)/ns.HookAu.startGold > ns.HookAu.maxGoldP then
        return false
    end
    return true
end

-- SetBindingMacro("CTRL-X", "MyAddonMacro")
local  function do_next_au_auticker (index)
    if index > #auSearchItems then
        --print(GetServerTime(),"所有项目处理完毕")
        --ns.HookAu.LogInfo("处理",_currentIndex,_currentItem[1])
        if ns.HookAu.auOpend then
            C_Timer.After(3, StartAUScan )
            --print(GetServerTime(),"启动新的一轮 auTicker" ,StartAUScan)
            ns.HookAu.LogInfo("启动新的一轮 StartAUScan")
            return true
        end
    end
    return false
end

-- /console scriptErrors 1 
local function GAUTicker()
    if not jlEventFrame then 
        jlEventFrame = CreateFrame("Frame", "MyaujlEventFrame")
        jlEventFrame:RegisterEvent("UI_ERROR_MESSAGE")
        jlEventFrame:RegisterEvent("PLAYER_MONEY")
        jlEventFrame:RegisterEvent("CHAT_MSG_SYSTEM")
        jlEventFrame:RegisterEvent("AUCTION_BIDDER_LIST_UPDATE")
    end 

    if not ns.HookAu.auOpend then
        return
    end
    if ns.HookAu.auDoItemsing then
        ns.HookAu.LogError("物品处理中。。")
        C_Timer.After(1.5, GAUTicker)
        return 
    end
    if not checkGold() then
        ns.HookAu.LogError("金币达到上限 终止扫货 ")
        return
    end
    
    local _doBuy = nil 
    local auAUDoItems = nil 
    local waitBuyList = {}

    local auProcessItemFunc = nil 
    local _currentIndex = 0;

    _doBuy = function ()
        ns.HookAu.auDoItemsing = true 
        if #waitBuyList == 0 then 
            ns.HookAu.auDoItemsing = false
            ns.HookAu.LogError("_doBuy call auProcessItemFunc " ,_currentIndex)
            C_Timer.After(0.5, function() auProcessItemFunc(_currentIndex)   end )
            return
        end
        local _buyitem = table.remove(waitBuyList,1)
        ns.HookAu.LogWarn("购买-_doBuy",#waitBuyList,_buyitem)
        Signal_001(function ()
            --print(GetServerTime(), "Signal_001" ) 
            --ns.ThreeDimensionsCode.Signal_001_CallBack = nil
            -- 每次只能买一件 
            index,seller,itemLink,stackPrice,count,avgGold = unpack(_buyitem)
            ns.HookAu.LogWarn("购买",index,seller,itemLink,stackPrice,count)
            PlaceAuctionBid("list", index, stackPrice)
            -- 再次遍历
            -- C_Timer.After(0.3, _doJL )
        end)
    end


    auAUDoItems = function ()
        local _currentItem = auSearchItems[_currentIndex];
        local _itemname, _goldavg , _min , _max = unpack(_currentItem)
        ns.HookAu.auDoItemsing = true
        waitBuyList = {}
        for index = 1, GetNumAuctionItems("list") do
            local auctionInfo = { GetAuctionItemInfo("list", index) }
            local itemLink = GetAuctionItemLink("list", index)
            ----- 统计当前情况 
            local item_name = auctionInfo[1]
            local stackPrice = auctionInfo[Auctionator.Constants.AuctionItemInfo.Buyout]

            local count = auctionInfo[Auctionator.Constants.AuctionItemInfo.Quantity]
            local seller = auctionInfo[Auctionator.Constants.AuctionItemInfo.Owner]
            if not seller then 
                seller = "-"
            end 
            local avgGold = stackPrice/count/10000
            local SaleStatus = auctionInfo[Auctionator.Constants.AuctionItemInfo.SaleStatus]
            
            if item_name == _itemname  and avgGold>0 and avgGold <= _goldavg and count >= _min and count <= _max and  SaleStatus == 0 then
                ns.HookAu.LogWarn("购买-预备",index,seller,itemLink,stackPrice,avgGold)
                table.insert(waitBuyList,{index,seller,itemLink,stackPrice,count,avgGold})
            end
        end
        -- 异步购买
        if #waitBuyList >= 1 then
            _doBuy()
        else
            if ns.HookAu.auOpend and _currentIndex+1 <= #auSearchItems then
                --print(GetServerTime(),"下一个物品",_currentIndex+1)
                C_Timer.After(5, function() auProcessItemFunc(_currentIndex + 1) end)
            else
                do_next_au_auticker(_currentIndex+1)
            end
        end
        ns.HookAu.auDoItemsing = false
    end

    
    auProcessItemFunc =  function (index)
        if not ns.HookAu.auOpend then
            return
        end
        _currentIndex = index 
        if do_next_au_auticker(_currentIndex) then
            return
        end
        local _currentItem = auSearchItems[_currentIndex]
        -- 在这里处理每个项目
        ns.HookAu.LogInfo("处理",_currentIndex,_currentItem[1])
        QueryAuctionItems(_currentItem[1], nil, nil , 0, nil, nil, false, true, nil)
        --QueryAuctionItems( nil , nil, nil , 0, nil, nil, false, true, AuctionCategories[6].filters)
        C_Timer.After(3, auAUDoItems)
        -- 设置下一个项目的处理，延迟3秒
    end



    jlEventFrame:SetScript("OnEvent", function(self, eventName, ...)
        ns.HookAu.LogInfo(eventName)
        --if eventName == "AUCTION_BIDDER_LIST_UPDATE" then
        if eventName == "PLAYER_MONEY" then 
            C_Timer.After(0.5, auAUDoItems)
        elseif eventName == "UI_ERROR_MESSAGE" then
            local _, message = ...
            ns.HookAu.LogInfo(eventName,message)
            if message == "未找到指定物品"  then
                C_Timer.After(0.5, _doBuy)
            end
            if message == "内部拍卖错误"  then
                C_Timer.After(0.5, _doBuy)
            end

        elseif eventName == "CHAT_MSG_SYSTEM" then
            local message = ...
            ns.HookAu.LogWarn(message,message == ERR_AUCTION_MIN_BID)
            if message == ERR_AUCTION_MIN_BID then
                C_Timer.After(0.5, auAUDoItems)
            end
        end
    end)
    canQuery,canQueryAll = CanSendAuctionQuery()
    -- print( GetServerTime(), "auTicker  canQuery:", canQuery,ns.HookAu.auDoItemsing,"auOpend",ns.HookAu.auOpend)
    if canQuery and not ns.HookAu.auDoItemsing and ns.HookAu.auOpend then
        SortAuctionSetSort("list", "unitprice")
        auProcessItemFunc(1)
    else
        -- 暂时无法搜索 
        -- ns.HookAu.LogError("搜索按钮不可用 稍后重试。。")
        C_Timer.After(3, GAUTicker)
    end

end
-- 全局函数

function StartAUScan()
    GAUTicker()
end


--- 捡漏啊 
--- 
--- 
local auSearchJLItems = ns.HookAu.auSearchJLItems

local function createCategoryFilterIterator()
    -- 定义一个表来存储我们需要的顺序
    local order = {2,4,10, 6, 9}
    local index = 0  -- 初始化索引

    -- 返回一个闭包函数
    return function()
        index = index + 1  -- 每次调用时增加索引
        
        -- 如果索引超出了order的长度，就从头开始
        if index > #order then
            index = 1
        end

        -- 获取当前索引对应的AuctionCategories的filters
        local categoryIndex = order[index]
        if AuctionCategories[categoryIndex] then
            return AuctionCategories[categoryIndex].filters
        else
            return nil  -- 如果找不到对应的分类，返回nil
        end
    end
end
local getNextFilters = createCategoryFilterIterator()

-- 新的捡漏机制 按物品上架时间
-- /script QueryAuctionItems(nil, 0, 0, 53, false, 0, false, false, nil)
-- /run SortAuctionClearSort("list")
-- /run SortAuctionSetSort("list", 'seller', false);SortAuctionSetSort("list", 'quantity', false);SortAuctionSetSort("list", 'unitprice', false);
-- /run SortAuctionApplySort("list")
local _tsm_total_au_items  = 0 
local _tsm_pages = 0

-- 1 捡漏 
-- 2 售卖 
ns.HookAu.jlAndSellState = 0 

function GAUTickerJIANLOU_TSM() 
    if ns.HookAu.jlAndSellState == 2  then 
        ns.HookAu.LogWarn(" GAUTickerJIANLOU_TSM 开始售卖 ， 停止捡漏  ") 
        -- return C_Timer.After(30, GAUTickerJIANLOU_TSM)
        return 
    end

    if not jlEventFrame then 
        jlEventFrame = CreateFrame("Frame", "MyaujlEventFrame")
        jlEventFrame:RegisterEvent("UI_ERROR_MESSAGE")
        jlEventFrame:RegisterEvent("PLAYER_MONEY")
        jlEventFrame:RegisterEvent("CHAT_MSG_SYSTEM")
        jlEventFrame:RegisterEvent("AUCTION_BIDDER_LIST_UPDATE")

    end 
    auJLLoopCount = auJLLoopCount + 1
    if not ns.HookAu.auOpend then
        return
    end
 
    if not checkGold() then
        ns.HookAu.LogError("金币达到上限 终止扫货 ")
        return
    end
    local _doJL = nil 
    local _doBuy = nil 
    
    canQuery,canQueryAll = CanSendAuctionQuery()
    -- print( GetServerTime(), "auTicker  canQuery:", canQuery,ns.HookAu.auDoItemsing,"auOpend",ns.HookAu.auOpend)  
    local waitBuyList = {}
    _doBuy = function () 
        if #waitBuyList == 0 then 

            ns.HookAu.LogError("_doBuy call GAUTickerJIANLOU_TSM " )
            C_Timer.After(0.5, function() GAUTickerJIANLOU_TSM()  end )
            return
        end
        local _canQuery,_canQueryAll = CanSendAuctionQuery()
        if(not _canQuery) then
            ns.HookAu.LogError("_doBuy not  _canQuery wait 0.3" )
            return C_Timer.After(0.3, _doBuy)
        end
        local _buyitem = table.remove(waitBuyList,#waitBuyList)
        Signal_001(function ()
            --print(GetServerTime(), "Signal_001" ) 
            -- ns.ThreeDimensionsCode.Signal_001_CallBack = nil
            -- 每次只能买一件 
            index,seller,itemLink,stackPrice,count,avgGold = unpack(_buyitem)
            ns.HookAu.LogWarn("购买",index,seller,itemLink,stackPrice,count,avgGold)
            PlaceAuctionBid("list", index, stackPrice)
            -- 再次遍历
            -- C_Timer.After(0.3, _doJL )
        end)
    end
     _doJL = function () 

        if ns.HookAu.jlAndSellState == 2  then 
            ns.HookAu.LogWarn(" GAUTickerJIANLOU_TSM - _doJL 开始售卖 ， 停止捡漏  ") 
            -- return C_Timer.After(30, GAUTickerJIANLOU_TSM)
            return 
        end
        
        -- 这里需要重置 buylist 
        waitBuyList = {}
        local __batchcount, __total  = GetNumAuctionItems("list") 
        _tsm_total_au_items = __total 
        _tsm_pages = ceil(_tsm_total_au_items / 50) - 1 
        for index = 1, __batchcount do
            local auctionInfo = { GetAuctionItemInfo("list", index) }
            local itemname = auctionInfo[1]
            local stackPrice = auctionInfo[Auctionator.Constants.AuctionItemInfo.Buyout]
            local _itemid = auctionInfo[Auctionator.Constants.AuctionItemInfo.ItemID]
            local count = auctionInfo[Auctionator.Constants.AuctionItemInfo.Quantity]
            local _level = auctionInfo[Auctionator.Constants.AuctionItemInfo.Level]
            local seller = auctionInfo[Auctionator.Constants.AuctionItemInfo.Owner]
            local avgGold = stackPrice/count/10000
            local SaleStatus = auctionInfo[Auctionator.Constants.AuctionItemInfo.SaleStatus]
            local itemLink = GetAuctionItemLink("list", index)
            local res = auSearchJLItems[itemname]
            local _, _, _, _, _, _, _, _, _, _, _sellPrice = GetItemInfo(_itemid)
            local _sellGold = _sellPrice/10000
            --print(itemname, avgGold,_sellGold,(_sellGold - avgGold)/avgGold)
            if res then
                if avgGold>0 and avgGold <= res and SaleStatus == 0   then
                    -- 抢  
                    ns.HookAu.LogWarn("购买-预备",index,seller,itemLink,stackPrice,count,avgGold)
                    table.insert(waitBuyList,{index,seller,itemLink,stackPrice,count,avgGold})                 
                elseif avgGold > 0 and (_sellGold - avgGold)/avgGold>0.05 then
                    ns.HookAu.LogWarn("购买-卖商店",index,seller,itemLink,stackPrice,count,avgGold,_sellGold)
                    table.insert(waitBuyList,{index,seller,itemLink,stackPrice,count,avgGold}) 
                --elseif _level>=80 and  then
                else
                    --print(GetServerTime(),"不抢",index,seller,itemname,avgGold,count)
                end
            
            elseif seller == "Wwssw" or seller == "老猎手二号" then
                ns.HookAu.LogWarn("购买-指定小号",index,seller,itemLink,stackPrice,count,avgGold)
                table.insert(waitBuyList,{index,seller,itemLink,stackPrice,count,avgGold})  
            end

            --print(GetServerTime(),itemLink,stackPrice,count,)
        end
        -- 异步购买
        if #waitBuyList >= 1 then
            _doBuy()
        else
            C_Timer.After(1, GAUTickerJIANLOU_TSM)
        end
    end

 
    jlEventFrame:SetScript("OnEvent", function(self, eventName, ...)
        local _, message = ...
        ns.HookAu.LogInfo(eventName,message)
        -- if eventName == "AUCTION_BIDDER_LIST_UPDATE" then
        if eventName == "PLAYER_MONEY" then 
            C_Timer.After(0.3, _doJL)
        elseif eventName == "UI_ERROR_MESSAGE" then
            
            if message == ERR_AUCTION_DATABASE_ERROR  then
                C_Timer.After(0.5, _doBuy)
            end

            if message == ERR_ITEM_NOT_FOUND  then
                C_Timer.After(0.1, _doBuy)
            end
        elseif eventName == "CHAT_MSG_SYSTEM" then
            local message = ...
            -- 你的出价必须不低于最低竞标价
            if message == ERR_AUCTION_MIN_BID then
                C_Timer.After(0.5, _doJL)
            end
        end
    end)


    --ns.HookAu.LogInfo(canQuery,ns.HookAu.auDoItemsing ,ns.HookAu.auOpend)
    if canQuery and   ns.HookAu.auOpend then
        -- SortAuctionSetSort("list", "unitprice")
        SortAuctionClearSort("list")
        QueryAuctionItems( nil , nil, nil , _tsm_pages , nil, nil, false, false, nil ) 
        
        if auJLLoopCount % 100 == 0 then
            ns.HookAu.LogInfo(_tsm_pages,_tsm_total_au_items)
            ns.HookAu.LogInfo("搜索中...搜索次数:" ,auJLLoopCount )
        end
        C_Timer.After(1, _doJL)
 
    else
        -- 暂时无法搜索 
        -- ns.HookAu.LogError("搜索按钮不可用 稍后重试。。")
        C_Timer.After(2, GAUTickerJIANLOU_TSM)
    end


end 

function GAUTickerJIANLOU()
    
    if not jlEventFrame then 
        jlEventFrame = CreateFrame("Frame", "MyaujlEventFrame")
        jlEventFrame:RegisterEvent("UI_ERROR_MESSAGE")
        jlEventFrame:RegisterEvent("PLAYER_MONEY")
        jlEventFrame:RegisterEvent("CHAT_MSG_SYSTEM")
        jlEventFrame:RegisterEvent("AUCTION_BIDDER_LIST_UPDATE")

    end 
    auJLLoopCount = auJLLoopCount + 1
    if not ns.HookAu.auOpend then
        return
    end
    if ns.HookAu.auDoItemsing then
        ns.HookAu.LogError("物品处理中。。")
        C_Timer.After(1.5, GAUTickerJIANLOU)
        return 
    end
    if not checkGold() then
        ns.HookAu.LogError("金币达到上限 终止扫货 ")
        return
    end
    local _doJL = nil 
    local _doBuy = nil 

    canQuery,canQueryAll = CanSendAuctionQuery()
    -- print( GetServerTime(), "auTicker  canQuery:", canQuery,ns.HookAu.auDoItemsing,"auOpend",ns.HookAu.auOpend)  
    local waitBuyList = {}
    _doBuy = function ()
        ns.HookAu.auDoItemsing = true 
        if #waitBuyList == 0 then 
            ns.HookAu.auDoItemsing = false 

            ns.HookAu.LogError("_doBuy call GAUTickerJIANLOU " )
            C_Timer.After(0.5, function() GAUTickerJIANLOU()  end )
            return
        end

  
        local _buyitem = table.remove(waitBuyList,#waitBuyList)
        Signal_001(function ()
            --print(GetServerTime(), "Signal_001" ) 
            -- ns.ThreeDimensionsCode.Signal_001_CallBack = nil
            -- 每次只能买一件 
            index,seller,itemLink,stackPrice,count,avgGold = unpack(_buyitem)
            ns.HookAu.LogWarn("购买",index,seller,itemLink,stackPrice,count)
            PlaceAuctionBid("list", index, stackPrice)
            -- 再次遍历
            -- C_Timer.After(0.3, _doJL )
        end)
    end




     _doJL = function () 
        -- 这里需要重置 buylist 
        waitBuyList = {}
        for index = 1, GetNumAuctionItems("list") do
            local auctionInfo = { GetAuctionItemInfo("list", index) }
            local itemname = auctionInfo[1]
            local stackPrice = auctionInfo[Auctionator.Constants.AuctionItemInfo.Buyout]
            local count = auctionInfo[Auctionator.Constants.AuctionItemInfo.Quantity]
            local seller = auctionInfo[Auctionator.Constants.AuctionItemInfo.Owner]
            local avgGold = stackPrice/count/10000
            local SaleStatus = auctionInfo[Auctionator.Constants.AuctionItemInfo.SaleStatus]
            local itemLink = GetAuctionItemLink("list", index)
            local res = auSearchJLItems[itemname]
            if res then
                if avgGold>0 and avgGold <= res and SaleStatus == 0   then
                    -- 抢  
                    ns.HookAu.LogWarn("购买-预备",index,seller,itemLink,stackPrice,count)
                    table.insert(waitBuyList,{index,seller,itemLink,stackPrice,count,avgGold})
                else
                    --print(GetServerTime(),"不抢",index,seller,itemname,avgGold,count)
                end
            end

            --print(GetServerTime(),itemLink,stackPrice,count,)
        end
        -- 异步购买
        if #waitBuyList >= 1 then
            _doBuy()
        else
            ns.HookAu.auDoItemsing = false
            C_Timer.After(1, GAUTickerJIANLOU)
        end
    end

 
    jlEventFrame:SetScript("OnEvent", function(self, eventName, ...)
        ns.HookAu.LogInfo(eventName)
        -- if eventName == "AUCTION_BIDDER_LIST_UPDATE" then
        if eventName == "PLAYER_MONEY" then 
            C_Timer.After(0.3, _doJL)
        elseif eventName == "UI_ERROR_MESSAGE" then
            local _, message = ...
            if message == ERR_ITEM_NOT_FOUND  then
                C_Timer.After(0.1, _doBuy)
            end
        elseif eventName == "CHAT_MSG_SYSTEM" then
            local message = ...
            -- 你的出价必须不低于最低竞标价
            if message == ERR_AUCTION_MIN_BID then
                C_Timer.After(0.5, _doJL)
            end
        end
    end)


    --ns.HookAu.LogInfo(canQuery,ns.HookAu.auDoItemsing ,ns.HookAu.auOpend)
    if canQuery and not ns.HookAu.auDoItemsing and ns.HookAu.auOpend then
        SortAuctionSetSort("list", "unitprice")
        QueryAuctionItems( nil , nil, nil , 0, nil, nil, false, true, getNextFilters())
        if auJLLoopCount % 50 == 0 then
            ns.HookAu.LogInfo("搜索中...搜索次数:" ,auJLLoopCount )
        end
        C_Timer.After(1, _doJL)
    end

end








auEventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "AUCTION_HOUSE_SHOW" then
        print(GetServerTime(), "拍卖行已打开。",myTicker)
        ns.HookAu.auOpend  = true
        --myTicker = C_Timer.NewTicker(15, auTicker)
        --print(ns.ThreeDimensionsCode)
        --myTicker = C_Timer.NewTimer(3,GAUTicker)
        -- ns.myTicker = C_Timer.NewTimer(3,GAUTicker)  
    elseif event == "AUCTION_OWNED_LIST_UPDATE" then
        -- 出售商品变动 
        local _, message = ...
        --print(event,_,message)
    elseif event == "AUCTION_BIDDER_LIST_UPDATE" then
        --print(GetServerTime(), "AUCTION_BIDDER_LIST_UPDATE")
        local _ = ...
    elseif event == "UI_ERROR_MESSAGE" then
        local _, message = ...
        if message == ERR_ITEM_NOT_FOUND  then
            ns.HookAu.hasError = true
        end
    elseif event == "AUCTION_HOUSE_CLOSED" then
        print("拍卖行已关闭。",myTicker,jlEventFrame)
        if jlEventFrame then 
            jlEventFrame:UnregisterAllEvents() -- 停止接收所有事件
            jlEventFrame:Hide() -- 隐藏Frame
            jlEventFrame = nil -- 移除引用，使其可以被垃圾收集器回收
        end 
        ns.HookAu.auOpend  = false
        ns.HookAu.auDoItemsing = false
        if ns.myTicker  and not ns.myTicker:IsCancelled() then
            ns.myTicker:Cancel()
        end
    end
end)




-------------------------------------------
------ 出售 

local _noneSlotIndex = {}
ns.HookAu.auNoneSlotIndex = _noneSlotIndex 
local auSellItems = ns.HookAu.auSellItems


local _sellInit = false 
local function initItemSellConf()
    if _sellInit then
        return 
    end
    _sellInit = true 
    local _itemDolist = {}
    for i = 1 , #ns.HookAu.auSellItemsRegex do
        --print(auSellItems[i])
        local _item = ns.HookAu.auSellItemsRegex[i]
        local   _itemname, _goldavg , _goldmax , _max, _firstMinZhanbi ,_checkCount= unpack(_item)
           
        for bagID = 0, 4 do
            -- 获取当前背包的物品槽数量
            local numSlots = C_Container.GetContainerNumSlots(bagID)
            -- 遍历当前背包的所有物品槽
            for slot = 1, numSlots do
                -- 获取物品槽的信息
                local slotinfo = C_Container.GetContainerItemInfo(bagID, slot)
                -- 如果物品槽不为空
                if slotinfo then
                    if not _itemDolist[slotinfo.itemName]  and   string.sub(_itemname,1,1) == "^" and string.match(slotinfo.itemName, _itemname)   then
                        local _t = {slotinfo.itemName, _goldavg , _goldmax , _max, _firstMinZhanbi,_checkCount }
                        table.insert(auSellItems,_t)
                        _itemDolist[slotinfo.itemName] = true 
                    end
                end
            end
        end
    end 
end




local  function do_next_au_seller(index)
    if index > #auSellItems then
        print(GetServerTime(),"所有项目处理完毕")
        if ns.HookAu.auOpend then
            C_Timer.After(5, ns.HookAu.auDoItemSell  )
            print(GetServerTime(),"启动新的一轮 auDoItemSell" ,ns.HookAu.auDoItemSell )
            return true
        end
    end
    return false
end


local function auGetItemSlotByName(itemName)
    for bagID = 0, 4 do
        -- 获取当前背包的物品槽数量
        local numSlots = C_Container.GetContainerNumSlots(bagID)
        -- 遍历当前背包的所有物品槽
        for slot = 1, numSlots do
            -- 获取物品槽的信息
            local slotinfo = C_Container.GetContainerItemInfo(bagID, slot)
            -- 如果物品槽不为空
            if slotinfo then
                -- 输出物品信息
                -- print(bagID,slot,slotinfo.itemID,slotinfo.itemName) 
                if slotinfo.itemName == itemName then
                    return bagID ,slot, slotinfo
                end
                -- if string.sub(itemName,1,1) == "^" and string.match(slotinfo.itemName, itemName)   then
                --     return bagID ,slot, slotinfo
                -- end
            end
        end
    end
    return nil , nil ,nil
end



local function auSearchItemOnSell(index) 
    if ns.HookAu.jlAndSellState == 1  then 
        ns.HookAu.LogWarn("auSearchItemOnSell 开始捡漏 ， 停止售卖 ") 
        --return C_Timer.After(30, auDoItemSell)
        return 
    end


    if  _noneSlotIndex[index] then
        return auSearchItemOnSell(index+1)
    end 
    if do_next_au_seller(index) then
        return 
    end
    if not ns.HookAu.auOpend then 
        return
    end
    local _item = auSellItems[index]
    ns.HookAu.LogDebug(_item,index)
    -- _firstMinZhanbi 在搜索第一页我的商品组数
    local _itemname, _goldavg , _goldmax , _max, _firstMinZhanbi ,_checkCount= unpack(_item)
    
    local _myCount = 0 -- 我的商品数量
    local function auAUDoSellItems()
        -- 遍历统计物品 
        if not ns.HookAu.auOpend then
            return
        end
        local _total = 0
        local _totalGold = 0
        local _minAvgGold=100000
        local _avgList = {}
        local _myName = UnitName("player");
        local _myHasSell = false
        for index = 1, GetNumAuctionItems("list") do
            local auctionInfo = { GetAuctionItemInfo("list", index) }
            ----- 统计当前情况 
            local stackPrice = auctionInfo[Auctionator.Constants.AuctionItemInfo.Buyout]
            local count = auctionInfo[Auctionator.Constants.AuctionItemInfo.Quantity]
            local seller = auctionInfo[Auctionator.Constants.AuctionItemInfo.Owner]
            local avgGold = stackPrice/count/10000
            local SaleStatus = auctionInfo[Auctionator.Constants.AuctionItemInfo.SaleStatus]
            _totalGold = _totalGold + stackPrice/10000

            if _myName == seller and index < _checkCount then
                -- 前15里面有自己
                _myCount = _myCount + 1 
                _myHasSell = true 
            end
            if _minAvgGold>avgGold then
                _minAvgGold = avgGold
            end
            _total = _total + count
            table.insert(_avgList,avgGold)
        end
        print(_itemname,_totalGold,_total) 
        if   _total == 0  then 
            _total = 1 
            table.insert(_avgList,1000000)
        end 
        local _curGoldAvg = _totalGold/_total
        local _priceGold = ns.HookAu.calculateSalePrice(_avgList)
        if _priceGold < _goldavg then 
            _priceGold = _goldavg 
        end 
        if _priceGold > _goldmax then 
            _priceGold = _goldmax
        end
        ns.HookAu.LogInfo("当前物品 " .. _itemname, "我的商品:",_myCount ,_myHasSell, "平均值:" .. _curGoldAvg , "最低价:" .. _minAvgGold , "建议出价：" .. _priceGold)
        -- 判断我自己当前的 ,等30秒 
        if _myHasSell and ns.HookAu.auOpend and _myCount >= _firstMinZhanbi    then
            ns.HookAu.LogInfo("存在我的商品,暂时不补货")
            return C_Timer.After(10, function() auSearchItemOnSell(index + 1) end)
        end

        -- 获取背包 
        local bagID ,slot, slotinfo = auGetItemSlotByName(_itemname)
        --print(bagID ,slot, slotinfo)
        if  bagID and slot and slotinfo then
            local _count = slotinfo.stackCount
            if  _count>_max then
                _count = _max 
            end
            C_Container.PickupContainerItem(bagID, slot)
            C_Timer.After(1, function ()
                local infoType = GetCursorInfo()
                if infoType == "item" then
                    ClickAuctionSellItemButton()
                    C_Timer.After(0.8,function()
                        -- PostAuction(13184,13185,2,20,1)
                        ns.HookAu.LogInfo("等待键盘事件",_itemname,_priceGold)
                        Signal_001(function ()
                            --print(GetServerTime(), "Signal_001" ) 
                            -- ns.ThreeDimensionsCode.Signal_001_CallBack = nil
                            -- 每次只能买一件 
                            ns.HookAu.LogInfo("上架",_itemname,math.floor(_priceGold*10000-1)*_count, math.floor(_priceGold*10000-1)*_count, 2, _count , 1)
                            PostAuction(math.floor(_priceGold*10000-1)*_count, math.floor(_priceGold*10000-1)*_count, 2, _count , 1) 
                            C_Timer.After(3, function() auSearchItemOnSell(index + 1)  end)
                        end)
                    end) 
                end
            end)

            return 
        else
            -- 背包里找不到商品，从表里剔除 
            -- table.remove(auSellItems, index)
            _noneSlotIndex[index] = 1 
        end

        if ns.HookAu.auOpend and index+1 <= #auSellItems then
            -- print(GetServerTime(),"下一个物品",index+1)
            C_Timer.After(10, function() auSearchItemOnSell(index + 1) end)
        else
            do_next_au_seller(index+1)
        end
    end

    QueryAuctionItems(_itemname, nil, nil , 0, nil, nil, false, true, nil)
    C_Timer.After(3, auAUDoSellItems)
end



local function auDoItemSell() 

    initItemSellConf()
    ns.HookAu.auSellItems = auSellItems



    if ns.HookAu.jlAndSellState == 1  then 
        ns.HookAu.LogWarn("auDoItemSell 开始捡漏 ， 停止售卖 ") 
        --return C_Timer.After(30, auDoItemSell)
        return 
    end

    
    local canQuery,canQueryAll = CanSendAuctionQuery()
    if canQueryAll then
        SortAuctionSetSort("list", "unitprice")
        auSearchItemOnSell(1)
    end
end

ns.HookAu.auDoItemSell = auDoItemSell

-- C_Timer.After(3, auDoItemSell)