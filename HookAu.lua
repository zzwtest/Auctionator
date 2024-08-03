

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


-- local function myFunction()
--     print("这个函数每30秒执行一次。")
--     QueryAuctionItems("白", 1, 10, 0, nil, nil, false, false, nil)
-- end

-- -- 创建一个定时器，每10秒钟调用一次myFunction
-- local myTicker = C_Timer.NewTicker(30, myFunction)

-- print(GetNumAuctionItems("list"))
-- for index = 1, GetNumAuctionItems(view) do
    
--     local auctionInfo = { GetAuctionItemInfo(view, index) }
--     local itemLink = GetAuctionItemLink(view, index)
--     local timeLeft = GetAuctionItemTimeLeft(view, index)
--     local entry = {
--       info = auctionInfo,
--       itemLink = itemLink,
--       timeLeft = timeLeft - 1, --Offset to match Retail time parameters
--       index = index,
--     }

--     ----- 统计当前情况 
--     -- print("Auctionator.AH.DumpAuctions(view",index,auctionInfo,itemLink,timeLeft) 
--     local stackPrice = auctionInfo[Auctionator.Constants.AuctionItemInfo.Buyout]
--     local count = auctionInfo[Auctionator.Constants.AuctionItemInfo.Quantity]
--     -- print(itemLink,stackPrice,count,stackPrice/count/10000)

--     -----
--     table.insert(auctions, entry)
--   end