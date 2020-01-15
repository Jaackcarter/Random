public String Matryoshka(DataObject_HUHeader ParentHU, String strContext = "", ADCULHub.ADCUL_WS_ConnectionDetails _ConnectionDetails = null)
{
   // This function returns a string list of contexts for all items within a given HU.
   // This includes child HU's down to max depth level.
   HandlingUnitContent HandlingUnitContent = new HandlingUnitContent(ParentHU.HUID, ParentHU.HUSysID, _ConnectionDetails);

   // Get the distinct context(s) for each item of given HU.
   foreach (DataObject_HUItem Item in HandlingUnitContent.ItemList)
   {
      if (String.IsNullOrWhiteSpace(strContext))
      {
         strContext = Item.DistrictCode + "/" + Item.WarehouseSCAID;
      }
      else
      {
         // Ignore the context if it already exists in the list.
         if (!strContext.Contains(Item.DistrictCode + "/" + Item.WarehouseSCAID))
         {
            strContext += ", " + Item.DistrictCode + "/" + Item.WarehouseSCAID;
         }
      }
   }

   // Recurse function for child HU.
   foreach (DataObject_HUHeader ChildHU in HandlingUnitContent.ChildHeaderList)
   {
       strContext = Matryoshka(ChildHU, strContext, _ConnectionDetails);
   }

   return strContext;
}