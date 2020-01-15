/*******************************************************************************
System                : Project
File Name             : ListBoxItemWarehouses.fn
Script Description    : see https://www.reddit.com/r/SQLServer/comments/eori2f/i_need_help_with_a_hierarchy_relation_type_of/
Written By            : u/jaackery
Date                  : January 15, 2020
********************************************************************************
********************************************************************************/
if exists (
   select name
   from sysobjects
   where type = 'FN'
   and   name = 'ListBoxItemWarehouses_fn'
)
   drop function ListBoxItemWarehouses_fn;
go

create function ListBoxItemWarehouses_fn (
   @inpBoxID            udtDeviceID,
   @inpWarehouseList    varchar(1000) = ''
)
returns varchar(1000)
as

/********************************************************************************
Version   Date         By            Action
---------+------------+-------------+--------------------------------------------
##> 1.00 | 15/01/2020 | u/jaackery  | First version.
         |            |             |
         |            |             |
********************************************************************************/

begin
   declare
      @Looper        int,
      @Warehouse     varchar(40),
      @ChildID       udtDeviceID;

   ---------------------------------------------
   -- Get distinct contexts for given HU items.
   ---------------------------------------------
   declare cItem cursor local for
      select distinct WhLocation
      from BoxItem
      where BoxID = @inpBoxID

   open cItem;

   set @Looper = 0;
   while @Looper = 0 begin
      fetch next from cItem
      into @Warehouse;

      set @Looper = @@fetch_status;
      if @Looper = 0  begin
         if @inpWarehouseList = ''
            set @inpWarehouseList = @Warehouse;
         else
            -- ignore context if already in the list.
            if charindex(@Warehouse, @inpWarehouseList) = 0  set @inpWarehouseList = @inpWarehouseList + ', '+ @Warehouse;
      end;

   end; -- while @Looper = 0

   close cItem;
   deallocate cItem;

   ---------------------------------------------
   -- Get children
   ---------------------------------------------
   declare cChildBox cursor local for
      select BoxID
      from BoxHeader
      where BoxID in (select ChildID from BoxChild where BoxID = @inpBoxID)

   open cChildBox;

   set @Looper = 0;
   while @Looper = 0 begin
      fetch next from cChildBox
      into @ChildID

      set @Looper = @@fetch_status;
      if @Looper = 0  begin
         -- Recurse
         select @inpWarehouseList = dbo.ListBoxItemWarehouses_fn(@ChildID, @inpWarehouseList);
      end;

   end; -- while @Looper = 0

   close cChildBox;
   deallocate cChildBox;

   return @inpWarehouseList;

end;
go


/*****************************
select dbo.ListBoxItemWarehouses_fn(1000, default);

*****************************/