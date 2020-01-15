public String Matryoshka(DataObject_BoxHeader ParentBox, String strWarehouseList = "", ADCULHub.ADCUL_WS_ConnectionDetails _ConnectionDetails = null)
{
   // This function returns a string list of warehouses for all items within a given Box.
   // This includes child Boxes down to max depth level.
   BoxContent BoxContent = new BoxContent(ParentBox.BoxID);

   // Get the distinct warehouse(s) for each item of given Box.
   foreach (DataObject_BoxItem Item in BoxContent.ItemList)
   {
      if (String.IsNullOrWhiteSpace(strWarehouseList))
      {
         strWarehouseList = Item.WhLocation;
      }
      else
      {
         // Ignore the warehouse if it already exists in the list.
         if (!strWarehouseList.Contains(Item.WhLocation))
         {
            strWarehouseList += ", " + Item.WhLocation;
         }
      }
   }

   // Recurse function for child Box.
   foreach (DataObject_BoxHeader ChildBox in BoxContent.ChildBoxList)
   {
       strWarehouseList = Matryoshka(ChildBox, strWarehouseList);
   }

   return strWarehouseList;
}