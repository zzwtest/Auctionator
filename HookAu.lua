
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

ns.HookAu = {}
ns.HookAu.auDoItemsing = false
ns.HookAu.auOpend = false
local auSearchItems ={
    -- 物品名, 单价(gold), 最小数量,最大数量
    {"铜矿石",0.37,3,20},
    {"铁矿石",0.9,1,20},
    {"瑟银锭",0.87,1,20},
    {"青铜锭",0.75,1,20},

} 
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
        print(GetServerTime(),"所有项目处理完毕")
        if ns.HookAu.auOpend then 
            C_Timer.After(5, GAUTicker )
            print(GetServerTime(),"启动新的一轮 auTicker" ,GAUTicker) 
            return true 
        end 
    end
    return false 
end

    


local function auProcessItem(index)
    if do_next_au_auticker(index) then
        return 
    end
    local _item = auSearchItems[index]
    local function auAUDoItems()
        ns.HookAu.auDoItemsing = true 
        local waitBuyList = {}
        for index = 1, GetNumAuctionItems("list") do
            local auctionInfo = { GetAuctionItemInfo("list", index) }
            local itemLink = GetAuctionItemLink("list", index)
            local timeLeft = GetAuctionItemTimeLeft("list", index)
            local entry = {
                info = auctionInfo,
                itemLink = itemLink,
                timeLeft = timeLeft - 1, --Offset to match Retail time parameters
                index = index,
            }
    
            ----- 统计当前情况 
            -- print("Auctionator.AH.DumpAuctions(view",index,auctionInfo,itemLink,timeLeft) 
            local stackPrice = auctionInfo[Auctionator.Constants.AuctionItemInfo.Buyout]
            local count = auctionInfo[Auctionator.Constants.AuctionItemInfo.Quantity] 
            local seller = auctionInfo[Auctionator.Constants.AuctionItemInfo.Owner]
            local avgGold = stackPrice/count/10000 
            local SaleStatus = auctionInfo[Auctionator.Constants.AuctionItemInfo.SaleStatus]
            local _itemname, _goldavg , _min , _max = unpack(_item)
            if avgGold>0 and avgGold <= _goldavg and count >= _min and count <= _max and  SaleStatus == 0 then
                print(GetServerTime(),index,seller,itemLink,stackPrice,count,avgGold) 
                -- Auctionator.AH.PlaceAuctionBid(index, stackPrice)
                -- PlaceAuctionBid("list", index, stackPrice)
                -- PlaceAuctionBid("list", 2, 8056)
                --ns.ThreeDimensionsCode:Signal_001()
                table.insert(waitBuyList,{index,seller,itemLink,stackPrice,count,avgGold})
            end
            --print(GetServerTime(),itemLink,stackPrice,count,)
        end
        -- 异步购买
        if #waitBuyList >= 1 then 
            ns.ThreeDimensionsCode:Signal_001(function ()
                print(GetServerTime(), "Signal_001" ) 
                ns.ThreeDimensionsCode.Signal_001_CallBack = nil
                -- 每次只能买一件 
                -- for i=1,#waitBuyList do
                index,seller,itemLink,stackPrice,count,avgGold = unpack(waitBuyList[1])
                print("购买",index, stackPrice)
                PlaceAuctionBid("list", index, stackPrice)
                -- 再次遍历 
                C_Timer.After(1, auAUDoItems ) 
                --end
                --C_Timer.After(5, function() auProcessItem(index + 1) end) 
                -- 避免重复触发 
            end)
        else 
            -- ns.ThreeDimensionsCode.Signal_001_CallBack = nil
            if ns.HookAu.auOpend and index+1 <= #auSearchItems then 
                print(GetServerTime(),"下一个物品",index+1)
                C_Timer.After(5, function() auProcessItem(index + 1) end)
            else 
                do_next_au_auticker(index+1)   
            end
        end
        ns.HookAu.auDoItemsing = false
    end
    -- 在这里处理每个项目
    print(GetServerTime(),"处理项目: ", _item[1])
    QueryAuctionItems(_item[1], nil, nil , 0, nil, nil, false, true, nil)
    C_Timer.After(3, auAUDoItems)
    -- 设置下一个项目的处理，延迟3秒
end

-- 全局函数
function GAUTicker()
    if not checkGold() then
        print(GetServerTime(),"金币达到上限 终止扫货 ")
        return 
    end
    canQuery,canQueryAll = CanSendAuctionQuery()
    print( GetServerTime(), "auTicker  canQuery:", canQuery,ns.HookAu.auDoItemsing,"auOpend",ns.HookAu.auOpend) 
    if canQuery and not ns.HookAu.auDoItemsing and ns.HookAu.auOpend then 
        SortAuctionSetSort("list", "unitprice")
        auProcessItem(1)
    end

end

local auEventFrame = CreateFrame("Frame", "MyauEventFrame")
auEventFrame:RegisterEvent("AUCTION_HOUSE_SHOW")
auEventFrame:RegisterEvent("AUCTION_HOUSE_CLOSED")
local myTicker = nil
auEventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "AUCTION_HOUSE_SHOW" then
        
        print(GetServerTime(), "拍卖行已打开。",myTicker)
        ns.HookAu.auOpend  = true
        --myTicker = C_Timer.NewTicker(15, auTicker)
        --print(ns.ThreeDimensionsCode)
        myTicker = C_Timer.NewTimer(3,GAUTicker)
    elseif event == "AUCTION_HOUSE_CLOSED" then
        print("拍卖行已关闭。",myTicker)
        ns.HookAu.auOpend  = false
        if myTicker and not myTicker:IsCancelled() then 
            myTicker:Cancel()
        end 
    end
end) 
