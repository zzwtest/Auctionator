
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


local auDoItemsing = false
local function myAUDoItems()
    auDoItemsing = true 
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
        if avgGold>0 and avgGold < 0.08 then
            print(GetServerTime(),index,seller,itemLink,stackPrice,count,avgGold) 
            -- Auctionator.AH.PlaceAuctionBid(index, stackPrice)
            -- PlaceAuctionBid("list", index, stackPrice)
            -- PlaceAuctionBid("list", 2, 8056)
            auDoItemsing = false
            return 
        end
        --print(GetServerTime(),itemLink,stackPrice,count,)

    end 
    auDoItemsing = false
end
-- SetBindingMacro("CTRL-X", "MyAddonMacro")





local function myAUTicker()
    canQuery,canQueryAll = CanSendAuctionQuery()
    print( GetServerTime(), "myAUTicker  canQuery:", canQuery,auDoItemsing) 
    if canQuery and not auDoItemsing then 
        --SortAuctionSetSort("list", "unitprice")
        --QueryAuctionItems("奥杜尔的圣物", nil, nil , 0, nil, nil, false, true, nil)
        --C_Timer.After(3, myAUDoItems)
    end 
    
end

local auEventFrame = CreateFrame("Frame", "MyauEventFrame")
auEventFrame:RegisterEvent("AUCTION_HOUSE_SHOW")
auEventFrame:RegisterEvent("AUCTION_HOUSE_CLOSED")
local myTicker = nil
auEventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "AUCTION_HOUSE_SHOW" then
        print(GetServerTime(), "拍卖行已打开。",myTicker)
        myTicker = C_Timer.NewTicker(10, myAUTicker)
        --print(ns.ThreeDimensionsCode)
        ns.ThreeDimensionsCode:send("hhhhh")
    elseif event == "AUCTION_HOUSE_CLOSED" then
        print("拍卖行已关闭。",myTicker) 
        if myTicker and not myTicker:IsCancelled() then 
            myTicker:Cancel()
        end 
    end
end) 
