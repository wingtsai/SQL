CREATE PROCEDURE [dbo].[Usp_GetHardwareMatrixReport_Pagination]  
(  
 @PartnerId INT,   
    @IsShowTestStep INT,  
 @IsShowReleaseStep INT,   
    @IsShowCompleteStep INT,   
 @IsFilterSelected INT,   
 @IsAllowQuickFilters INT,   
    @VendorIds VARCHAR(max),   
 @Rohs INT,   
 @EOL INT,   
 @PartnerIds VARCHAR(max),   
 @QualStatusIds VARCHAR(max),   
 @DevInputIds VARCHAR(max),   
 @SCRestricted VARCHAR(10),   
 @DevManagerIds VARCHAR(max),   
 @CommodityPMIds VARCHAR(max),   
 @PhaseIds VARCHAR(max),   
 @CategoryIds VARCHAR(max),   
 @RootIds VARCHAR(max),   
 @SubAssemblyIds VARCHAR(max),   
 @ReportFormat INT,   
 @FamilyIds VARCHAR(max),   
 @ProductGroupIds VARCHAR(max),   
 @TeamIds VARCHAR(max),   
 @Advanced VARCHAR(max),   
 @ReportSplit INT,   
 @ChangeType VARCHAR(20),   
 @HighlightRow VARCHAR(max),   
 @ProductReleaseIds VARCHAR(max),   
 @FullReport INT,   
 @QueryString VARCHAR(max),   
 @CompleteDateStart VARCHAR(50),   
 @CompleteDateEnd VARCHAR(50),   
 @SpecificPilotStatus VARCHAR(100),   
 @SpecificQualStatus VARCHAR(100),   
 @HistoryRange VARCHAR(10),   
 @StartDate VARCHAR(50),   
 @EndDate VARCHAR(50),   
 @NoOfHistoryDays INT,   
 @Products VARCHAR(max),  
 @Type INT,  
 @FileType VARCHAR(10),  
 @PageNo        INT,   
 @PageSize      INT,   
 @OrderByClause VARCHAR (200),   
 @WhereClause   VARCHAR (MAX),  
 @ExcelColumnLimit  INT=500  
 --@ColumnPageNo int = 1,  
 --@ColumnPageSize int = 100  
  
)  
AS  
BEGIN  
 DECLARE @ErrorMessage VARCHAR(MAX)='',@PrdCount INT=0 ,@ColumnLimit INT=@ExcelColumnLimit  
 --BEGIN TRAN HWTrans  
 BEGIN TRY  
 DECLARE @StepFilter   VARCHAR(max)='',   
   @Filter       NVARCHAR(max)='',   
   @VendorFilter NVARCHAR(max)=''   
  
  
  IF ISNULL(@PartnerId,'') <>'' AND cast(@PartnerId as varchar(50)) <> 1   
  BEGIN   
  SET @Filter = N'and (pv.Partnerid in (''' + Convert(varchar(max),@PartnerId)  
      +   
  ''') or  (pv.Partnerid in (SELECT ProductPartnerId FROM PartnerODMProductWhitelist WHERE UserPartnerId ='  
     + Convert(varchar(max),@PartnerId) + ')))'   
  END   
  
  IF Isnull(@VendorIds, '') <> ''   
  BEGIN   
  SET @Filter = @Filter   
     +   
  ' and v.vendorid in (SELECT value FROM  dbo.Ufn_split('''+ @VendorIds + ''','',''))'   
  END   
  
  IF @Rohs = '1'   
  BEGIN   
  SET @Filter = @Filter + ' and v.rohsid=1 '   
  END   
  ELSE IF @Rohs = '2'   
  BEGIN   
  SET @Filter = @Filter + ' and v.greenspecid=1 '   
  END   
  
  IF Isnull(@EOL, '') <> ''   
  BEGIN   
  SET @Filter = @Filter + ' and v.active=' + cast(@EOL as varchar(10))  
  END   
  
  IF Isnull(@PartnerIds, '') <> ''   
  BEGIN   
  SET @Filter = @Filter   
     +   
  ' and pv.Partnerid in (SELECT value FROM  dbo.Ufn_split('''   
     + @PartnerIds + ''','',''))'   
  END   
  
  IF Isnull(@QualStatusIds, '') <> ''   
  BEGIN   
  IF @QualStatusIds LIKE'%-1%'   
  BEGIN   
   SET @Filter = @Filter   
       + ' and ((isnull(pv.FusionRequirements, 0) = 0 and (pd.TestStatusid in  (SELECT value FROM  dbo.Ufn_split('''   
       + @QualStatusIds   
       + ''','','')) or (pd.TestStatusid=5 and pd.RiskRelease=1))) or   (isnull(pv.FusionRequirements, 0) = 1 and (pdr.TestStatusid  in (SELECT value FROM  dbo.Ufn_split('''   
       + @QualStatusIds   
       +   
   ''','','')) or (pdr.TestStatusid=5 and pdr.RiskRelease=1))))'   
  END   
  ELSE IF 1 = 1   
  BEGIN   
   SET @Filter = @Filter   
       +   
   ' and ((isnull(pv.FusionRequirements, 0) = 0 and    pd.TestStatusid in (SELECT value FROM  dbo.Ufn_split('''   
       + @QualStatusIds   
       +   
  ''','','')))     or (isnull(pv.FusionRequirements, 0) = 1 and pdr.TestStatusid in (SELECT value FROM  dbo.Ufn_split('''  
      + @QualStatusIds + ''','',''))))'   
  END   
  END   
  
  IF Isnull(@DevInputIds, '') <> ''   
  BEGIN   
  SET @Filter = @Filter   
     +   
  ' and ((isnull(pv.FusionRequirements, 0) = 0 and CONVERT(INT,ISNULL(pd.DeveloperNotificationStatus,0)) in (SELECT value FROM  dbo.Ufn_split('''   
    + @DevInputIds + ''','','')))  or (isnull(pv.FusionRequirements, 0) = 1 and CONVERT(INT,ISNULL(pdr.DeveloperNotificationStatus,0)) in (SELECT value FROM  dbo.Ufn_split('''   
    + @DevInputIds + ''','',''))))'   
  END   
  
  IF Isnull(@SCRestricted, '') <> ''   
  BEGIN   
  SET @Filter = @Filter   
     +   
  ' and ((isnull(pv.FusionRequirements, 0) = 0 and pd.SupplyChainRestriction=1) or (isnull(pv.FusionRequirements, 0) = 1 and pdr.SupplyChainRestriction=1)) '  
  END   
  
  IF Isnull(@DevManagerIds, '') <> ''   
  BEGIN   
  SET @Filter = @Filter   
     +   
  ' and r.DevManagerid in (SELECT value FROM  dbo.Ufn_split('''   
     + @DevManagerIds + ''','',''))'   
  END   
  
  IF Isnull(@CommodityPMIds, '') <> ''   
  BEGIN   
  SET @Filter = @Filter   
     + ' and pv.PDEID in (SELECT value FROM  dbo.Ufn_split('''   
     + @CommodityPMIds + ''','',''))'   
  END   
  
  IF Isnull(@PhaseIds, '') <> ''   
  BEGIN   
  SET @Filter = @Filter   
     + ' and ps.ID in (SELECT value FROM  dbo.Ufn_split('''   
     + @PhaseIds + ''','',''))'   
  END   
  
  IF Isnull(@CategoryIds, '') <> ''   
  BEGIN   
  SET @Filter = @Filter   
     +   
  ' and r.Categoryid in (SELECT value FROM  dbo.Ufn_split('''   
     + @CategoryIds + ''','',''))'   
  END   
  
  IF Isnull(@RootIds, '') <> ''   
  BEGIN   
  SET @Filter = @Filter   
     + ' and r.id in (SELECT value FROM  dbo.Ufn_split('''  
     + @RootIds + ''','',''))'   
  END   
  
  IF Isnull(@SubAssemblyIds, '') <> ''   
  AND @ReportFormat = 2   
  BEGIN   
  SET @Filter = @Filter   
     +   
  ' and ((prr.ID is null and pr.base in (SELECT value FROM  dbo.Ufn_split('''   
   + @SubAssemblyIds   
   +   
  ''','','')))  or (prr.ID is not null and prr.base in (SELECT value FROM  dbo.Ufn_split('''   
  + @SubAssemblyIds + ''','',''))))'   
  END   
  ELSE IF Isnull(@SubAssemblyIds, '') <> ''   
  AND @ReportFormat = 5   
  BEGIN   
  SET @Filter = @Filter   
   + ' and (( prr.ID is null and (pr.servicebase is null  and pr.base in (SELECT value FROM  dbo.Ufn_split('''   
   + @SubAssemblyIds   
   + ''','',''))) or pr.servicebase in  (SELECT value FROM  dbo.Ufn_split('''   
   + @SubAssemblyIds   
   +   
  ''','',''))) or ( prr.ID is not null and  (prr.servicebase is null and prr.base in (SELECT value FROM  dbo.Ufn_split('''   
  + @SubAssemblyIds   
  + ''','','')))  or prr.servicebase in (SELECT value FROM  dbo.Ufn_split('''   
  + @SubAssemblyIds + ''','','')) ))'   
  END   
  
  IF Isnull(@FamilyIds, '') <> ''   
  BEGIN   
  SET @Filter = @Filter   
     +   
  ' and pv.productfamilyid in (SELECT value FROM  dbo.Ufn_split('''   
     + @FamilyIds + ''','','')) '   
  END   
  
  DECLARE @Cyclist            VARCHAR(max)='',   
  @LastProductGroup   VARCHAR(max)='0',   
  @ProductGroupFilter VARCHAR(max)=''   
  DECLARE @ProductGroups TABLE   
  (   
  id             INT IDENTITY(1, 1),   
  productgroupid VARCHAR(max)   
  )   
  DECLARE @Index          INT=1,   
  @TotalCount     INT=0,   
  @ProductGroupId VARCHAR(max)   
  DECLARE @GroupId   VARCHAR(max),   
  @ProductId VARCHAR(max)   
  DECLARE @GroupSql NVARCHAR(max)=''   
  DECLARE @ProductVersionIds VARCHAR(max)=''   
  DECLARE @PulsarProducts VARCHAR(max)=''   
  DECLARE @ProductSqlQuary NVARCHAR(max)   
  
  IF Isnull(@ProductReleaseIds, '') <> ''   
  BEGIN   
  SET @ProductSqlQuary =   
  'SELECT DISTINCT ProductVersionID FROM ProductVersion_Release WITH (NOLOCK) WHERE ID IN (SELECT value FROM  dbo.Ufn_split('''  
  + @ProductReleaseIds + ''','',''))'   
  
  DECLARE @TBLProductVersion TABLE   
  (   
  id INT   
  )   
  
  INSERT INTO @TBLProductVersion   
  EXECUTE Sp_executesql   
  @ProductSqlQuary   
  
  SELECT @PulsarProducts = @PulsarProducts + ','   
       + CONVERT(VARCHAR(max), id)   
  FROM   @TBLProductVersion   
  
  IF Isnull(@PulsarProducts, '') <> ''   
  AND Isnull(@Products, '') <> ''   
  BEGIN   
  SET @Products = @PulsarProducts +','  + @Products   
  END   
  END   
  
  IF Isnull(@Products, '') = ''   
  AND Isnull(@PulsarProducts, '') <> ''   
  BEGIN   
  SET @Products = @PulsarProducts   
  END   
  
  IF Isnull(@Products, '') <> ''   
  AND Isnull(@PulsarProducts, '') = ''   
  BEGIN   
  SET @Products = @Products   
  END   
  
  IF LEFT(@Products, 1) = ','   
  BEGIN   
  SET @Products = Substring(@Products, 2, Len(@Products))   
  END   
  
  SET @ProductVersionIds = @Products   
  
  IF Isnull(@ProductGroupIds, '') <> ''   
  BEGIN   
  INSERT INTO @ProductGroups   
  SELECT value   
  FROM   dbo.Ufn_split(@ProductGroupIds, ',')   
  
  SELECT @TotalCount = Max(id)   
  FROM   @ProductGroups   
  
  PRINT @ProductGroupIds   
  
  WHILE( @Index <= @TotalCount )   
  BEGIN   
   SELECT @ProductGroupId = productgroupid   
   FROM   @ProductGroups   
   WHERE  id = @Index   
  
   IF @ProductGroupId <> ''   
    BEGIN   
     SET @GroupId = Substring(@ProductGroupId, 0,   
         Charindex(':', @ProductGroupId)   
         )   
     SET @ProductId = Substring(@ProductGroupId,   
         Charindex(':', @ProductGroupId   
         )   
         + 1, Len(   
             @ProductGroupId))   
  
     IF @LastProductGroup <> '0'   
      AND @GroupId <> '2'   
      AND @LastProductGroup <> @GroupId   
     BEGIN   
      SET @ProductGroupFilter =   
      @ProductGroupFilter + ') and '   
     END   
  
     IF @LastProductGroup <> @GroupId   
     BEGIN   
      IF @GroupId = '1'   
       BEGIN   
        SET @ProductGroupFilter =   
        @ProductGroupFilter + '( partnerid ='   
        + @ProductId   
        SET @LastProductGroup = @GroupId   
       END   
  
      IF @GroupId = '2'   
       BEGIN   
        SET @Cyclist = @Cyclist + ',' + @ProductId   
       END   
  
      IF @GroupId = '3'   
       BEGIN   
        SET @ProductGroupFilter =   
        @ProductGroupFilter + '( devcenter ='   
        + @ProductId   
        SET @LastProductGroup = @GroupId   
       END   
  
      IF @GroupId = '4'   
       BEGIN   
        SET @ProductGroupFilter =   
        @ProductGroupFilter + '( productstatusid ='   
        + @ProductId   
        SET @LastProductGroup = @GroupId   
       END   
     END   
     ELSE   
     BEGIN   
      IF @GroupId = '1'   
       BEGIN   
        SET @ProductGroupFilter =   
        @ProductGroupFilter + ' or partnerid ='   
        + @ProductId   
        SET @LastProductGroup = @GroupId   
       END   
  
      IF @GroupId = '2'   
       BEGIN   
        SET @Cyclist = @Cyclist + ',' + @ProductId   
       END   
  
      IF @GroupId = '3'   
       BEGIN   
        SET @ProductGroupFilter =   
        @ProductGroupFilter + ' or devcenter ='   
        + @ProductId   
        SET @LastProductGroup = @GroupId   
       END   
  
      IF @GroupId = '4'   
       BEGIN   
        SET @ProductGroupFilter =   
        @ProductGroupFilter + ' or productstatusid ='   
        + @ProductId   
        SET @LastProductGroup = @GroupId   
       END   
     END   
  
     SET @Index = @Index + 1;   
    END   
  END   
  
  PRINT @ProductGroupFilter   
  
  IF Isnull(@ProductGroupFilter, '') <> ''   
  BEGIN   
   SET @GroupSql = @GroupSql + ' and (' + @ProductGroupFilter +   
       '))'   
  END   
  
  IF Isnull(@Cyclist, '') <> ''   
  BEGIN   
   SET @GroupSql = @GroupSql   
       +   
  ' and id in (Select ProductVersionid from product_program with (NOLOCK) where programid in (SELECT value FROM  dbo.Ufn_split('''  
   + Substring(@Cyclist, 2, Len(@Cyclist))   
   + ''','',''))) '   
  END   
  
  IF Isnull(@GroupSql, '') <> ''   
  BEGIN   
  SET @GroupSql = Substring(@GroupSql, 5, Len(@GroupSql))   
  END   
  
  DECLARE @GroupProductVersions TABLE   
  (   
  id INT   
  )   
  DECLARE @RowCount INT = 0,   
  @RowIndex INT =0   
  DECLARE @ProductSql NVARCHAR(max)   
  
  SET @ProductSql = N'Select ID from productversion with (NOLOCK) where '   
     + @GroupSql   
  
  PRINT @ProductSql   
  
  INSERT INTO @GroupProductVersions   
  EXECUTE Sp_executesql   
  @ProductSql   
  
  SELECT @ProductVersionIds = ISNULL(@ProductVersionIds,'') + ','   
       + CONVERT(VARCHAR(max), id)   
  FROM   @GroupProductVersions   
  END   
  
  IF @ProductVersionIds = ''   
  BEGIN   
  SET @ProductVersionIds = '0'   
  END   
  ELSE   
  PRINT @ProductVersionIds   
   
  
  IF Isnull(@ProductVersionIds, '') <> ''   
  BEGIN   
  SET @Filter = @Filter   
    + ' and pv.id in (SELECT value FROM  dbo.Ufn_split('''   
    + @ProductVersionIds + ''','','')) '   
  END   
  ELSE   
  BEGIN   
  SET @Filter = @Filter   
    +   
  ' and pv.id <> 100 and pv.oncommoditymatrix=1 and pv.productstatusid<5'   
  END   
  
  IF Isnull(@TeamIds, '') <> ''   
  BEGIN   
  SET @Filter = @Filter   
    + ' and c.teamid in (SELECT value FROM  dbo.Ufn_split('''   
    + @TeamIds + ''','',''))'   
  END   
  
  IF Isnull(@Advanced, '') <> ''   
  BEGIN   
  SET @Filter = @Filter + '  and (' + @Advanced + ')'   
  END   
  
  IF Isnull(@CompleteDateStart, '') <> ''   
  AND Isnull(@CompleteDateEnd, '') <> ''   
  BEGIN   
   IF ISDATE(@CompleteDateStart)=1 AND ISDATE(@CompleteDateEnd)=1  
   BEGIN  
   SET @Filter = @Filter   
     + ' and ((isnull(pv.FusionRequirements, 0) = 0 and pd.teststatusid = 3 and DATEDIFF(D,'''+ @CompleteDateStart + ''', pd.TestDate) >= 0 and DATEDIFF(D,'''+ @CompleteDateEnd + ''',pd.TestDate)<=0)  
      or (isnull(pv.FusionRequirements, 0) = 1 and pdr.teststatusid = 3 and DATEDIFF(D,'''+ @CompleteDateEnd + ''', pdr.TestDate) >= 0 and DATEDIFF(D,'''+ @CompleteDateEnd + ''',pdr.TestDate)<=0))  
     '    
   END  
  END   
  
  IF @ReportSplit = 1   
  BEGIN   
  SET @Filter = @Filter   
    + ' and upper(pv.dotsname) >= ''A'''   
    + ' and upper(pv.dotsname) < ''N'''   
  END   
  ELSE IF @ReportSplit = 2   
  BEGIN   
  SET @Filter = @Filter   
    + ' and upper(pv.dotsname) >= ''N'''   
  END   
  
  DECLARE @HistoryFilter VARCHAR(max)='',   
  @PilotStatus   VARCHAR(100)='',   
  @QualStatus    VARCHAR(100)=''   
  
  IF Isnull(@ChangeType, '') <> ''   
  BEGIN   
  IF Isnull(@SpecificPilotStatus, '') <> ''   
  AND Charindex(':', @SpecificPilotStatus) > 0   
  AND Charindex('22', @ChangeType) > 0   
  BEGIN   
  DECLARE @FromId VARCHAR(50),   
    @ToId   VARCHAR(50)   
  
  SET @FromId = Substring(@SpecificPilotStatus, 0,   
      Charindex(':', @SpecificPilotStatus))   
  SET @ToId = Substring(@SpecificPilotStatus,   
     Charindex(':', @SpecificPilotStatus) + 1, Len(   
        @SpecificPilotStatus))   
  
  IF Isnull(@FromId, '') <> ''   
   BEGIN   
    SET @PilotStatus = @PilotStatus + ' and l.FromID in (' +   
         @FromId   
         + ') '   
   END   
  
  IF Isnull(@ToId, '') <> ''   
   BEGIN   
    SET @PilotStatus = @PilotStatus + ' and l.ToID in (' + @ToId +   
         ') '   
   END   
  END   
  
  IF Isnull(@SpecificQualStatus, '') <> ''   
  AND Charindex(':', @SpecificQualStatus) > 0   
  AND Charindex('21', @ChangeType) > 0   
  BEGIN   
  DECLARE @QualFromId VARCHAR(50),   
    @QualToId   VARCHAR(50)   
  
  SET @FromId = Substring(@SpecificQualStatus, 0,   
      Charindex(':', @SpecificQualStatus))   
  SET @ToId = Substring(@SpecificQualStatus,   
     Charindex(':', @SpecificQualStatus) + 1, Len(   
        @SpecificPilotStatus))   
  
  IF Isnull(@FromId, '') <> ''   
   BEGIN   
    SET @QualStatus = @QualStatus + ' and l.FromID in (' + @FromId   
        + ') '   
   END   
  
  IF Isnull(@ToId, '') <> ''   
   BEGIN   
    SET @QualStatus = @QualStatus + ' and l.ToID in (' + @ToId +   
        ') '   
   END   
  END   
  
  DECLARE @TempDate DATETIME   
  
  IF @HistoryRange = 'Range'   
  BEGIN   
  IF @StartDate IS NULL   
   BEGIN   
    SET @StartDate = CONVERT(VARCHAR(50), '1/1/1970')   
   END   
  
  IF @EndDate IS NULL   
   BEGIN   
    SET @EndDate = CONVERT(DATETIME, '1/1/1970')   
   END   
  
  IF Datediff(dd, @StartDate, @EndDate) < 0   
   BEGIN   
    SET @TempDate = @StartDate   
    SET @StartDate = @EndDate   
    SET @EndDate = @TempDate   
   END   
  END   
  ELSE   
  BEGIN   
  SET @TempDate = Dateadd(d, -@NoOfHistoryDays, Getdate())   
  
  IF @HistoryRange = '='   
   BEGIN   
    SET @StartDate = @TempDate   
    SET @EndDate = @TempDate   
   END   
  ELSE IF @HistoryRange = '>='   
   BEGIN   
    SET @StartDate = '1/1/1970'   
    SET @EndDate = @TempDate   
   END   
  ELSE   
   BEGIN   
    SET @StartDate = @TempDate   
    SET @EndDate = CONVERT(VARCHAR(50), Getdate())   
   END   
  END   
  
  DECLARE @StrReportRange NVARCHAR(max),   
   @StrDateRange   NVARCHAR(max)   
  
  IF @StartDate <> '1/1/1970'   
  BEGIN   
  SET @StrReportRange = N'<br><br><font size=1 face=verdana> '   
        + @StartDate + ' - ' + @EndDate +   
        '<BR><BR></font>'   
  END   
  ELSE   
  BEGIN   
  SET @StrReportRange = N'<br><br><font size=1 face=verdana> Before '   
        + @StartDate + ' <BR><BR></font>'   
  END   
  
  SET @StrDateRange = ' DATEDIFF(D,''' + @StartDate   
      + ''', l.Updated) >= 0 and DATEDIFF(D,DATEADD(d,1,'''   
      + @EndDate + '''),l.Updated)<=0'   
  
  DECLARE @TempSql NVARCHAR(max) =''  
  
  IF Charindex('21', @ChangeType) > 0   
  BEGIN   
  PRINT 'ChangeType'   
  
  SET @TempSql = @TempSql + ' Union Select pd.id from Actions a with (NOLOCK),  ActionLog l with (NOLOCK), ProductVersion p with (NOLOCK),  vendor vd with (NOLOCK), deliverableversion v with (NOLOCK),  deliverableroot r with (NOLOCK), TestStatus t1 with (
NOLOCK),  TestStatus t2 with (NOLOCK), product_deliverable pd with (NOLOCK)  where pd.productversionid = p.id and pd.deliverableversionid = v.id  and ' + @StrDateRange + @QualStatus   
      +   
  ' and t1.id = l.FromID  and t2.id = l.ToID and r.id = v.deliverablerootid and a.actionid = l.actionid and  v.id = l.deliverableversionid and vd.id = v.vendorid and l.productversionid = p.id and l.actionid in(21)'  
  END   
  
  IF Charindex('22', @ChangeType) > 0   
  BEGIN   
  SET @TempSql = @TempSql + ' Union Select pd.id from Actions a with (NOLOCK), ActionLog l with (NOLOCK),  ProductVersion p with (NOLOCK), vendor vd with (NOLOCK), deliverableversion v with (NOLOCK),  deliverableroot r with (NOLOCK), PilotStatus t1 with (
NOLOCK), PilotStatus t2 with (NOLOCK),  product_deliverable pd with (NOLOCK) where pd.productversionid = p.id and pd.deliverableversionid = v.id and  ' + @StrDateRange + @QualStatus   
      + ' and t1.id = l.FromID and t2.id = l.ToID and r.id = v.deliverablerootid  and a.actionid = l.actionid and v.id = l.deliverableversionid and vd.id = v.vendorid and l.productversionid = p.id and   l.actionid in (22)'   
  END   
  
  IF Isnull(@TempSql, '') <> ''   
  BEGIN   
  SET @TempSql = Substring(@TempSql, 8, Len(@TempSql))   
  END   
  
  SET @HistoryFilter = ' and pd.id in (' + @TempSql + ')' ---in Progress   
  END   
  
  IF @IsShowCompleteStep = 1   
  OR @IsShowReleaseStep = 1   
  OR @IsShowTestStep = 1   
  BEGIN   
  SET @Filter = @Filter   
    +   
  ' and v.status <> 5 and v.location not like ''Development%''   
   and ((isnull(pv.FusionRequirements, 0) = 0 and (pd.teststatusid <> 1 or     
   ( pd.teststatusid = 1 and pd.DeveloperNotificationStatus=1))) or     
   (isnull(pv.FusionRequirements, 0) = 1 and (pdr.teststatusid <> 1 or    
    ( pdr.teststatusid = 1 and pdr.DeveloperNotificationStatus=1)))) '   
  
  IF @IsShowCompleteStep = 1   
  BEGIN   
  SET @StepFilter = ' location like'   
     + '''%Workflow Complete%'''   
  END   
  
  IF @IsShowReleaseStep = 1   
  BEGIN   
  SET @StepFilter = CASE   
      WHEN Isnull(@StepFilter, '') = '' THEN   
      ' location like' + '''%Core Team%'''   
      ELSE ' location like'   
       + '''%Workflow Complete%'''   
       + ' or location like' + '''%Core Team%'''   
     END   
  END   
  
  IF @IsShowTestStep = 1   
  BEGIN   
  SET @StepFilter = CASE   
      WHEN Isnull(@StepFilter, '') = '' THEN   
      ' (location like ' + '''%Engineering%'''   
      + ' or location like ' + '''%Eng. Dev%''' + ')'   
      ELSE @StepFilter + ' or (location like '   
       + '''%Engineering%''' + ' or location like '   
       + '''%Eng. Dev%''' + ')'   
     END   
  END   
  
  IF Isnull(@StepFilter, '') <> ''   
  BEGIN   
  SET @Filter = @Filter + ' and (' + @StepFilter + ')'   
  END   
  END   
  ELSE   
  BEGIN   
  SET @Filter = @Filter   
    +   
  ' and ((isnull(pv.FusionRequirements, 0) = 0 and (pd.teststatusid <> 1 or ( pd.teststatusid = 1 and pd.DeveloperNotificationStatus=1 and v.location like ''%Workflow Complete%''))) or (isnull(pv.FusionRequirements, 0) = 1 and (pdr.teststatusid <> 1 or ( 
pdr.teststatusid = 1 and pdr.DeveloperNotificationStatus=1 and v.location like ''%Workflow Complete%''))))'  
  END   
  
  IF Isnull(@HighlightRow, '') <> ''   
  BEGIN   
  IF @Filter = ''   
  BEGIN   
  SET @Filter = @Filter   
      + ' and v.id in (SELECT value FROM  dbo.Ufn_split('''   
      + @HighlightRow + ''','',''))'   
  END   
  ELSE   
  BEGIN   
  SET @Filter = ' and (v.id in (SELECT value FROM  dbo.Ufn_split('''   
      + @HighlightRow + ''','','')) or ('   
      + Substring(@Filter, 5, Len(@Filter)) + '))'   
  END   
  END   
  
  IF Isnull(@ProductReleaseIds, '') <> ''   
  BEGIN   
  SET @Filter = @Filter   
    + ' and ((isnull(pv.FusionRequirements,0) = 0) or (isnull(pv.FusionRequirements,0) = 1 and  pvr.ID in (SELECT value FROM  dbo.Ufn_split('''   
    + @ProductReleaseIds + ''','',''))))'   
  END   
  
  DECLARE @ColumnCount      INT,   
  @SelectFieldQuery NVARCHAR(max),   
  @SelectFromQuery  NVARCHAR(max)   
  
  IF @ReportFormat = 4   
  BEGIN   
  SET @ColumnCount = 14   
  SET @SelectFieldQuery =   
  'Select  v.location, v.sampledate, case when pdr.ID is null then pd.TargetNotes else pdr.TargetNotes end as targetnotes, case when pdr.ID is null then pd.riskrelease else pdr.riskrelease end as riskrelease, gs.MatrixBGColor as GreenSpecBGColor, '  
  SET @SelectFieldQuery = @SelectFieldQuery   
      +   
  ' case when pdr.ID is null then a.MatrixBGColor else aRelease.MatrixBGColor end as AccessoryBGColor, c.commodity, '  
  SET @SelectFieldQuery = @SelectFieldQuery   
      +   
  ' case when pdr.ID is null then t.MatrixBGColor else tsRelease.MatrixBGColor end as MatrixBGColor, v.id as DeliverableVersionID, v.Serviceactive, '  
  SET @SelectFieldQuery = @SelectFieldQuery   
      +   
  ' v.active, v.serviceeoadate, v.endoflifedate as EOLDate, r.id as RootID, c.ID as CategoryID, v.assemblycode, cv.suppliercode as suppliercode, v.leadfree, v.rohsid, v.greenspecid, '  
  SET @SelectFieldQuery = @SelectFieldQuery   
      +   
  ' c.name as category, r.name as DeliverableName, case when pdr.ID is null then pd.testconfidence else pdr.testconfidence end as testconfidence, pd.productversionid, '''' as DCRSummary, '''' as SubAssembly, '''' as subassemblySpin, '''' as subassemblyBas
e, '  
  SET @SelectFieldQuery = @SelectFieldQuery   
      +   
  ' case when pdr.ID is null then a.Name else aRelease.Name end as AccessoryStatus, case when pdr.ID is null then pd.PilotDate else pdr.PilotDate end as AccessoryDate,  '  
  SET @SelectFieldQuery = @SelectFieldQuery   
      +   
  ' case when pdr.ID is null then t.status else tsRelease.Status end as TestStatus, case when pdr.ID is null then pd.TestDate else pdr.TestDate end as TestDate , vd.name as Vendor, v.version, v.revision,v.pass,v.partnumber,v.ModelNumber, pd.DCRID, v.endof
lifedate, r.Name as VersionDeliverableName, gs.name as greenSpec, rh.name as RoHS, Feature.FeatureName as FeatureName,FusionRequirements = isnull(pv.FusionRequirements, 0),ReleaseID = isnull(pvr.ReleaseID,0),convert(varchar(max),'''') AS DCRDesc,convert(v
archar(max),'''') AS EOLDateDesc,convert(varchar(max),'''') as VendorWithSupplier,convert(varchar(max),'''') as RohsGreenSpec,Convert(varchar(max),'''') as SubAssemblyBaseDesc,Convert(varchar(max),'''')  AS PilotStatusDesc,  
  Convert(varchar(max),'''') AS AccessoryStatusDesc, Convert(varchar(max),'''') AS TestStatusDesc, pv.DotsName,null as Bridged,NULL AS NativeSubassemblyRootID '  
  SET @SelectFromQuery = ' FROM dbo.DeliverableRoot AS r WITH (NOLOCK) '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  'INNER JOIN      dbo.DeliverableVersion AS v WITH (NOLOCK) ON r.ID = v.DeliverableRootID  '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  'INNER JOIN      dbo.Product_Deliverable AS pd WITH (NOLOCK) ON v.ID = pd.DeliverableVersionID '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  'INNER JOIN      dbo.ProductVersion AS pv WITH (NOLOCK) ON pv.ID = pd.ProductVersionID  '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  'INNER JOIN      dbo.ProductStatus AS ps WITH (NOLOCK) ON pv.ProductStatusID = ps.ID '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  'INNER JOIN      dbo.AccessoryStatus AS a WITH (NOLOCK) ON pd.AccessoryStatusID = a.ID  '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  'INNER JOIN      dbo.DeliverableCategory AS c WITH (NOLOCK) ON r.CategoryID = c.ID  '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  'INNER JOIN      dbo.ProductFamily AS f WITH (NOLOCK) ON f.ID = pv.ProductFamilyID '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  'INNER JOIN      dbo.GreenSpec AS gs WITH (NOLOCK)  ON gs.ID = v.GreenSpecID '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  'INNER JOIN      dbo.RoHS AS rh WITH (NOLOCK) ON v.RoHSID = rh.ID  '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  'INNER JOIN dbo.Vendor AS vd WITH (NOLOCK)  on vd.ID = v.VendorID '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  'LEFT OUTER JOIN dbo.TestStatus AS t WITH (NOLOCK) ON pd.TestStatusID = t.ID '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  'LEFT OUTER JOIN dbo.DeliverableCategory_Vendor AS cv WITH (NOLOCK)  ON c.ID = cv.DeliverableCategoryID AND  vd.ID = cv.VendorID '  
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  'LEFT OUTER JOIN dbo.Feature_Root AS FR WITH (NOLOCK) ON r.id = FR.ComponentRootID '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  'LEFT OUTER JOIN dbo.Feature WITH (NOLOCK) ON Feature.FeatureID = FR.FeatureID '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  'LEFT OUTER JOIN dbo.Product_Deliverable_Release pdr WITH(NOLOCK) ON pd.ID = pdr.ProductDeliverableID '  
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  'LEFT OUTER JOIN dbo.ProductVersion_Release pvr WITH(NOLOCK) ON pvr.ReleaseID = pdr.ReleaseID and pvr.ProductVersionID = pd.ProductVersionID '  
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  'LEFT OUTER JOIN dbo.ProductVersionRelease pvrelease WITH(NOLOCK) ON pvrelease.ID = pdr.ReleaseID '  
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  'LEFT OUTER JOIN dbo.AccessoryStatus aRelease WITH(NOLOCK) ON pdr.AccessoryStatusID = aRelease.ID '  
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  'LEFT OUTER JOIN dbo.TestStatus tsRelease WITH(NOLOCK) ON pdr.TestStatusID = tsRelease.ID '   
  
  SET @SelectFromQuery = @SelectFromQuery   
      + ' WHERE pv.typeid in (1,3)  '   
  SET @SelectFromQuery = @SelectFromQuery + ' AND c.accessory=1  '   
  SET @SelectFromQuery = @SelectFromQuery   
      + ' AND r.kitnumber<> ''''  '   
  SET @SelectFromQuery = @SelectFromQuery   
      + ' AND r.kitnumber is not null '   
  SET @SelectFromQuery = @SelectFromQuery   
      + ' AND r.rootfilename <> ''HFCN'' '   
  IF Isnull(@ChangeType, '') = ''   
  BEGIN   
  SET @SelectFromQuery = @SelectFromQuery   
        + ' and pd.accessorystatusid <> 0 '  
  --'  and ((isnull(pv.FusionRequirements, 0) = 0 and pd.teststatusid <> 0) or (isnull(pv.FusionRequirements, 0) = 1 and pdr.TestStatusid <> 0))  '  
  END   
  END   
  ELSE IF @ReportFormat = 5   
  BEGIN   
  SET @ColumnCount = 14   
  SET @SelectFieldQuery =   
  'Select v.location, v.sampledate, case when pdr.ID is null then pd.TargetNotes else pdr.TargetNotes end as targetnotes, case when pdr.ID is null then pd.riskrelease else pdr.riskrelease end as riskrelease, gs.MatrixBGColor as GreenSpecBGColor, p.MatrixB
GColor as PilotBGColor,   '  
  SET @SelectFieldQuery = @SelectFieldQuery   
      +   
  ' case when pdr.ID is null then t.MatrixBGColor else tsRelease.MatrixBGColor end as MatrixBGColor, v.id as DeliverableVersionID,v.serviceactive, v.active, v.serviceeoadate, v.endoflifedate as EOLDate, r.id as RootID, c.ID as CategoryID,   '  
  SET @SelectFieldQuery = @SelectFieldQuery   
      +   
  ' v.assemblycode, cv.suppliercode as suppliercode, v.leadfree, v.rohsid, v.greenspecid, c.name as category, r.name as DeliverableName,   '  
  SET @SelectFieldQuery = @SelectFieldQuery   
      +   
  ' case when pdr.ID is null then pd.testconfidence else pdr.testconfidence end as testconfidence, pd.productversionid, '''' as DCRSummary, case when prr.ID is null then coalesce(pr.servicesubassembly,pr.subassembly) else coalesce(prr.servicesubassembly,p
rr.subassembly) end as Subassembly,   '  
  SET @SelectFieldQuery = @SelectFieldQuery   
      +   
  ' coalesce(pr.servicespin,pr.spin) as subassemblySpin, case when prr.ID is null then coalesce(pr.servicebase,pr.Base) else coalesce(prr.servicebase,prr.Base) end as subassemblyBase, p.Name as PilotStatus, case when pdr.ID is null then pd.PilotDate else 
pdr.PilotDate end as PilotDate, '  
  SET @SelectFieldQuery = @SelectFieldQuery   
      +   
  ' case when pdr.ID is null then t.status else tsRelease.Status end as TestStatus, case when pdr.ID is null then pd.TestDate else pdr.TestDate end as TestDate, '  
  SET @SelectFieldQuery = @SelectFieldQuery   
      +   
  ' vd.name as Vendor, v.version, v.revision,v.pass,v.partnumber,v.ModelNumber, case when pdr.ID is null then pd.DCRID else pdr.DCRID end as DCRID, v.endoflifedate, r2.Name as VersionDeliverableName, r2.ID as NativeSubassemblyRootID, '  
  SET @SelectFieldQuery = @SelectFieldQuery   
      +   
  ' gs.name as greenSpec, rh.name as Rohs, Feature.FeatureName as FeatureName,FusionRequirements = isnull(pv.FusionRequirements, 0),ReleaseID = isnull(pvr.ReleaseID,0) ,convert(varchar(max),'''') AS DCRDesc,convert(varchar(max),'''') AS EOLDateDesc,conver
t(varchar(max),'''') as VendorWithSupplier,convert(varchar(max),'''') as RohsGreenSpec,Convert(varchar(max),'''') as SubAssemblyBaseDesc,Convert(varchar(max),'''')  AS PilotStatusDesc, Convert(varchar(max),'''') AS AccessoryStatusDesc, Convert(varchar(max
),'''') AS TestStatusDesc, Convert(varchar(max),'''')  as AccessoryStatus,Convert(varchar(max),'''') as AccessoryDate,convert(bit,0) as commodity, pv.DotsName,null as Bridged  '  
  SET @SelectFromQuery = ' FROM dbo.DeliverableCategory AS c WITH (NOLOCK)  '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' INNER JOIN dbo.DeliverableRoot AS r WITH (NOLOCK) ON c.ID = r.CategoryID  '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' INNER JOIN dbo.ProdDel_DelRoot AS pddr WITH (NOLOCK) ON r.ID = pddr.DeliverableRootID   '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' INNER JOIN dbo.Product_Deliverable AS pd WITH (NOLOCK) ON pd.ID = pddr.ProductDeliverableID  '  
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' INNER JOIN dbo.ProductVersion AS pv WITH (NOLOCK) ON pd.ProductVersionID = pv.ID  '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' INNER JOIN dbo.Userinfo as ui WITH (NOLOCK) ON r.DevManagerID = ui.UserId  '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' INNER JOIN dbo.ProductFamily AS f WITH (NOLOCK) ON pv.ProductFamilyID = f.ID  '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' INNER JOIN dbo.ProductStatus AS ps WITH (NOLOCK) ON pv.ProductStatusID = ps.ID  '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' INNER JOIN dbo.Product_DelRoot AS pr WITH (NOLOCK) ON r.ID = pr.DeliverableRootID AND pv.ID = pr.ProductVersionID '  
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' INNER JOIN dbo.DeliverableVersion AS v WITH (NOLOCK) ON pd.DeliverableVersionID = v.ID   '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' INNER JOIN dbo.DeliverableRoot AS r2 WITH (NOLOCK) ON v.DeliverableRootID = r2.ID  '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' INNER JOIN dbo.GreenSpec AS gs WITH (NOLOCK) ON v.GreenSpecID = gs.ID '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' INNER JOIN dbo.RoHS AS rh WITH (NOLOCK) ON v.RoHSID = rh.ID   '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' INNER JOIN dbo.Vendor AS vd WITH (NOLOCK) on vd.ID = v.VendorID  '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' LEFT OUTER JOIN dbo.PilotStatus AS p WITH (NOLOCK) ON p.ID = pd.PilotStatusID  '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' LEFT OUTER JOIN dbo.TestStatus AS t WITH (NOLOCK) ON t.ID = pd.TestStatusID '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' LEFT OUTER JOIN dbo.DeliverableCategory_Vendor AS cv WITH (NOLOCK) ON c.ID = cv.DeliverableCategoryID AND  vd.ID = cv.VendorID  '  
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' LEFT OUTER JOIN dbo.Feature_Root AS FR WITH (NOLOCK) ON r.id = FR.ComponentRootID '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' LEFT OUTER JOIN dbo.Feature WITH (NOLOCK) ON Feature.FeatureID = FR.FeatureID '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' LEFT OUTER JOIN dbo.Product_DelRoot_Release prr WITH(NOLOCK) ON pr.ID = prr.ProductDelRootID '  
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' LEFT OUTER JOIN dbo.Product_Deliverable_Release pdr WITH(NOLOCK) ON pd.ID = pdr.ProductDeliverableID '  
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' LEFT OUTER JOIN dbo.ProductVersion_Release pvr WITH(NOLOCK) ON pvr.ReleaseID = pdr.ReleaseID and pvr.ProductVersionID = pd.ProductVersionID '  
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' LEFT OUTER JOIN dbo.ProductVersionRelease pvrelease WITH(NOLOCK) ON pvrelease.ID = pdr.ReleaseID '  
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' LEFT OUTER JOIN dbo.TestStatus tsRelease WITH(NOLOCK) ON pdr.TestStatusID = tsRelease.ID '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' LEFT OUTER JOIN dbo.PilotStatus pRelease WITH(NOLOCK) ON pdr.PilotStatusID = pRelease.ID  '   
  SET @SelectFromQuery = @SelectFromQuery   
      + ' WHERE     ( r.RootFilename <> ''HFCN'' )  '   
  SET @SelectFromQuery = @SelectFromQuery + ' AND (r.TypeID = 1) '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' AND ((prr.ID is null AND (pr.ServiceSubassembly <> '''' or (pr.ServiceSubassembly is null and pr.Subassembly <> '''') ) AND (pr.ServiceSubassembly is not null or (pr.ServiceSubassembly is null and pr.Subassembly is not null))) '  
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' OR (prr.ID is not null AND (prr.ServiceSubassembly <> '''' or (prr.ServiceSubassembly is null and prr.Subassembly <> '''') ) AND (prr.ServiceSubassembly is not null or (prr.ServiceSubassembly is null and prr.Subassembly is not null))))'  
  
  IF @FullReport = 1   
  BEGIN   
  SET @SelectFromQuery = @SelectFromQuery   
        +   
  ' and c.commodity=1 and pv.typeid=1 and pv.productstatusid<4'   
  END   
  ELSE   
  BEGIN   
  SET @SelectFromQuery = @SelectFromQuery + ' and r.typeid=1 '   
  END   
  
  IF Isnull(@ChangeType, '') = ''   
  BEGIN   
  SET @SelectFromQuery = @SelectFromQuery   
        +   
  ' and ((isnull(pv.FusionRequirements, 0) = 0 and pd.teststatusid <> 0) or (isnull(pv.FusionRequirements, 0) = 1 and pdr.TestStatusid <> 0)) '  
  END   
  END   
  --ELSE IF @ReportFormat<>2 AND @ReportFormat<>5  
  ELSE IF @ReportFormat = 3 OR @ReportFormat = 1 OR @ReportFormat = 6 OR @ReportFormat = 0 -- changed on 07/07/2018  
  BEGIN  
  SET @SelectFieldQuery = 'Select  v.location,v.sampledate, case when pdr.ID is null then pd.TargetNotes else pdr.TargetNotes end as targetnotes, case when pdr.ID is null then pd.riskrelease else pdr.riskrelease end as riskrelease, gs.MatrixBGColor as Gre
enSpecBGColor, ui.FullName as ComponentPM, '  
  SET @SelectFieldQuery = @SelectFieldQuery + 'case when pdr.ID is null then p.MatrixBGColor else pRelease.MatrixBGColor end as PilotBGColor, case when pdr.ID is null then t.MatrixBGColor else tsRelease.MatrixBGColor end as MatrixBGColor, v.id as Delivera
bleVersionID '  
  SET @SelectFieldQuery = @SelectFieldQuery + ', v.Serviceactive, v.active, v.serviceeoadate, v.endoflifedate as EOLDate, r.id as RootID, c.ID as CategoryID, v.assemblycode, cv.suppliercode as suppliercode, v.leadfree, '  
  SET @SelectFieldQuery = @SelectFieldQuery + 'v.greenspecid, v.rohsid, c.name as category, r.name as DeliverableName, case when pdr.ID is null then pd.testconfidence else pdr.testconfidence end as testconfidence, pd.productversionid, '''' as DCRSummary, 
'''' as SubAssembly, '''' as subassemblySpin,'''' as subassemblyBase,  '  
  SET @SelectFieldQuery = @SelectFieldQuery + 'case when pdr.ID is null then p.Name else pRelease.Name end as PilotStatus, case when pdr.ID is null then pd.PilotDate else pdr.PilotDate end as PilotDate, '  
  SET @SelectFieldQuery = @SelectFieldQuery + 'case when pdr.ID is null then t.status else tsRelease.Status end as TestStatus, case when pdr.ID is null then pd.TestDate else pdr.TestDate end as TestDate, vd.name as Vendor, v.version, v.revision,v.pass,v.p
artnumber,v.ModelNumber, case when pdr.ID is null then pd.DCRID else pdr.DCRID end as DCRID, v.endoflifedate, r.Name as VersionDeliverableName, gs.name as greenSpec, rh.name as RoHS, Feature.FeatureName as FeatureName ,FusionRequirements = isnull(pv.Fusio
nRequirements, 0),ReleaseID = isnull(pvr.ReleaseID,0), '''' AS DCRDesc,'''' AS EOLDateDesc,convert(varchar(max),'''') as VendorWithSupplier,convert(varchar(max),'''') as RohsGreenSpec,Convert(varchar(max),'''') as SubAssemblyBaseDesc,Convert(varchar(max),
'''')  AS PilotStatusDesc, Convert(varchar(max),'''') AS AccessoryStatusDesc, Convert(varchar(max),'''') AS TestStatusDesc, Convert(varchar(max),'''')  as AccessoryStatus,Convert(varchar(max),'''') as AccessoryDate,convert(bit,0) as commodity, pv.DotsName
,null as Bridged,NULL AS NativeSubassemblyRootID   '   
  SET @SelectFromQuery ='FROM dbo.DeliverableRoot AS r WITH (NOLOCK) '  
  SET @SelectFromQuery = @SelectFromQuery +'INNER JOIN      dbo.DeliverableVersion AS v WITH (NOLOCK) ON r.ID = v.DeliverableRootID  '  
  SET @SelectFromQuery = @SelectFromQuery +'INNER JOIN      dbo.Product_Deliverable AS pd WITH (NOLOCK) ON v.ID = pd.DeliverableVersionID '  
  SET @SelectFromQuery = @SelectFromQuery +'INNER JOIN      dbo.ProductVersion AS pv WITH (NOLOCK) ON pv.ID = pd.ProductVersionID '    
  SET @SelectFromQuery = @SelectFromQuery +'INNER JOIN      dbo.Userinfo as ui WITH (NOLOCK) ON r.DevManagerID = ui.UserId  '  
  SET @SelectFromQuery = @SelectFromQuery +'INNER JOIN      dbo.ProductStatus AS ps WITH (NOLOCK) ON pv.ProductStatusID = ps.ID '  
  SET @SelectFromQuery = @SelectFromQuery +'INNER JOIN      dbo.DeliverableCategory AS c WITH (NOLOCK) ON r.CategoryID = c.ID   '  
  SET @SelectFromQuery = @SelectFromQuery +'INNER JOIN      dbo.ProductFamily AS f WITH (NOLOCK) ON f.ID = pv.ProductFamilyID  '  
  SET @SelectFromQuery = @SelectFromQuery +'INNER JOIN      dbo.Vendor AS vd WITH (NOLOCK)  on vd.ID = v.VendorID  '  
  SET @SelectFromQuery = @SelectFromQuery +'INNER JOIN      dbo.GreenSpec AS gs WITH (NOLOCK)  ON gs.ID = v.GreenSpecID '  
  SET @SelectFromQuery = @SelectFromQuery +'INNER JOIN      dbo.RoHS AS rh WITH (NOLOCK) ON v.RoHSID = rh.ID   '  
  SET @SelectFromQuery = @SelectFromQuery +'LEFT OUTER JOIN dbo.TestStatus AS t WITH (NOLOCK) ON pd.TestStatusID = t.ID  '  
  SET @SelectFromQuery = @SelectFromQuery +'LEFT OUTER JOIN dbo.pilotstatus p with (NOLOCK) ON  pd.pilotstatusid =p.id  '  
  SET @SelectFromQuery = @SelectFromQuery +'LEFT OUTER JOIN dbo.DeliverableCategory_Vendor AS cv WITH (NOLOCK)  ON c.ID = cv.DeliverableCategoryID AND vd.ID = cv.VendorID '  
  SET @SelectFromQuery = @SelectFromQuery +'LEFT OUTER JOIN dbo.Feature_Root AS FR WITH (NOLOCK) ON r.id = FR.ComponentRootID '  
  SET @SelectFromQuery = @SelectFromQuery +'LEFT OUTER JOIN dbo.Feature WITH (NOLOCK) ON Feature.FeatureID = FR.FeatureID '  
  SET @SelectFromQuery = @SelectFromQuery +'LEFT OUTER JOIN dbo.Product_Deliverable_Release pdr WITH(NOLOCK) ON pd.ID = pdr.ProductDeliverableID '  
  SET @SelectFromQuery = @SelectFromQuery +'LEFT OUTER JOIN dbo.ProductVersion_Release pvr WITH(NOLOCK) ON pvr.ReleaseID = pdr.ReleaseID and pvr.ProductVersionID = pd.ProductVersionID '  
  SET @SelectFromQuery = @SelectFromQuery +'LEFT OUTER JOIN dbo.ProductVersionRelease pvrelease WITH(NOLOCK) ON pvrelease.ID = pdr.ReleaseID '  
  SET @SelectFromQuery = @SelectFromQuery +'LEFT OUTER JOIN dbo.TestStatus tsRelease WITH(NOLOCK) ON pdr.TestStatusID = tsRelease.ID '  
  SET @SelectFromQuery = @SelectFromQuery +'LEFT OUTER JOIN dbo.PilotStatus pRelease WITH(NOLOCK) ON pdr.PilotStatusID = pRelease.ID   '  
  SET @SelectFromQuery = @SelectFromQuery +'WHERE pv.typeid in (1,3)   '  
  SET @SelectFromQuery = @SelectFromQuery +'AND r.rootfilename <> ''HFCN'''               
  
  IF @FullReport = 1   
  BEGIN   
  SET @SelectFromQuery = @SelectFromQuery   
        +   
  ' and c.commodity=1 and pv.typeid=1 and pv.productstatusid<4'   
  END   
  ELSE   
  BEGIN   
  SET @SelectFromQuery = @SelectFromQuery + ' and r.typeid=1 '   
  END   
  
  IF Isnull(@ChangeType, '') = ''   
  BEGIN   
  SET @SelectFromQuery = @SelectFromQuery +   
  ' and ((isnull(pv.FusionRequirements, 0) = 0 and pd.teststatusid <> 0) or (isnull(pv.FusionRequirements, 0) = 1 and pdr.TestStatusid <> 0)) '  
  END   
  END  
  ELSE   
  BEGIN   
  IF @ReportFormat = 6   
  BEGIN   
  SET @ColumnCount=15   
  END   
  ELSE   
  BEGIN   
  SET @ColumnCount=14   
  END   
  
  SET @SelectFieldQuery =   
  'Select v.location, v.sampledate, case when pdr.ID is null then pd.TargetNotes else pdr.TargetNotes end as targetnotes, case when pdr.ID is null then pd.riskrelease else pdr.riskrelease end as riskrelease, '  
  SET @SelectFieldQuery = @SelectFieldQuery   
      +   
  'gs.MatrixBGColor as GreenSpecBGColor, p.MatrixBGColor as PilotBGColor, '   
  SET @SelectFieldQuery = @SelectFieldQuery   
      +   
  'case when pdr.ID is null then t.MatrixBGColor else tsRelease.MatrixBGColor end as MatrixBGColor, v.id as DeliverableVersionID,v.serviceactive, v.active, '  
  SET @SelectFieldQuery = @SelectFieldQuery   
      +   
  'v.serviceeoadate, v.endoflifedate as EOLDate, r.id as RootID, c.ID as CategoryID,'   
  SET @SelectFieldQuery = @SelectFieldQuery   
      +   
  ' v.assemblycode, cv.suppliercode as suppliercode, v.leadfree,v.rohsid,'   
  SET @SelectFieldQuery = @SelectFieldQuery   
      +   
  'v.greenspecid, c.name as category, r.name as DeliverableName, case when pdr.ID is null then pd.testconfidence else pdr.testconfidence end as testconfidence,'  
  SET @SelectFieldQuery = @SelectFieldQuery   
      +   
  ' pd.productversionid, '''' as DCRSummary, case when prr.ID is null then pr.subassembly else prr.subassembly end as subassembly, case when prr.ID is null then pr.spin else prr.spin end as subassemblySpin,'  
  SET @SelectFieldQuery = @SelectFieldQuery   
      +   
  ' case when prr.ID is null then pr.Base else prr.Base end as subassemblyBase, case when pdr.ID is null then p.Name else p2.Name end as PilotStatus, case when pdr.ID is null then pd.PilotDate else pdr.PilotDate end as PilotDate,'  
  SET @SelectFieldQuery = @SelectFieldQuery   
      +   
  ' case when pdr.ID is null then t.status else tsRelease.Status end as TestStatus, case when pdr.ID is null then pd.TestDate else pdr.TestDate end as TestDate, vd.name as Vendor, v.version, v.revision,'  
  SET @SelectFieldQuery = @SelectFieldQuery   
      +   
  ' v.pass,v.partnumber,v.ModelNumber, case when pdr.ID is null then pd.DCRID else pdr.DCRID end as DCRID, v.endoflifedate,'   
  SET @SelectFieldQuery = @SelectFieldQuery   
      +   
  ' r2.Name as VersionDeliverableName, r2.ID as NativeSubassemblyRootID,'   
  SET @SelectFieldQuery = @SelectFieldQuery   
      +   
  ' gs.name as greenSpec, rh.name as Rohs,FusionRequirements = isnull(pv.FusionRequirements, 0),ReleaseID = isnull(pvr.ReleaseID,0),'  
  SET @SelectFieldQuery = @SelectFieldQuery   
      +   
  '  FeatureName= isnull((SELECT STUFF((select ''; '' + isnull(avdetail.AvNo, '''') + '' / '' +  avdetail.GPGDescription + '' / '' + feature.FeatureName '  
  SET @SelectFieldQuery = @SelectFieldQuery   
      + ' from Feature_Root  FR WITH (NOLOCK) '   
  SET @SelectFieldQuery = @SelectFieldQuery   
      +   
  '  inner join feature WITH (NOLOCK) on Feature.FeatureID = FR.FeatureID '   
  SET @SelectFieldQuery = @SelectFieldQuery   
      +   
  '      inner join avdetail WITH (NOLOCK) on avdetail.featureID=feature.featureID '   
  SET @SelectFieldQuery = @SelectFieldQuery   
      +   
  '      inner join AvDetail_ProductBrand apb WITH (NOLOCK) on avdetail.avdetailID= apb.AvDetailID '   
  SET @SelectFieldQuery = @SelectFieldQuery   
      +   
  '      inner join Product_Brand with (nolock) on apb.ProductBrandID=Product_Brand.ID '   
  SET @SelectFieldQuery = @SelectFieldQuery   
      + '  WHERE  FR.ComponentRootID = r.id    '   
  SET @SelectFieldQuery = @SelectFieldQuery   
      + '   and Product_Brand.ProductVersionID =pv.ID'   
  SET @SelectFieldQuery = @SelectFieldQuery   
      +   
  '  for xml path('''') ), 1, 2, '''')), ''Not linked'') ,convert(varchar(max),'''') AS DCRDesc,convert(varchar(max),'''') AS EOLDateDesc,convert(varchar(max),'''') as VendorWithSupplier,convert(varchar(max),'''') as RohsGreenSpec,Convert(varchar(max),''
'') as SubAssemblyBaseDesc,Convert(varchar(max),'''')  AS PilotStatusDesc, Convert(varchar(max),'''') AS AccessoryStatusDesc, Convert(varchar(max),'''') AS TestStatusDesc, Convert(varchar(max),'''')  as AccessoryStatus,Convert(varchar(max),'''') as Access
oryDate ,convert(bit,0) as commodity, pv.DotsName,null as Bridged  '   
  SET @SelectFromQuery = ' FROM dbo.DeliverableCategory AS c WITH (NOLOCK)  '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' INNER JOIN dbo.DeliverableRoot AS r WITH (NOLOCK) ON c.ID = r.CategoryID  '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' INNER JOIN dbo.ProdDel_DelRoot AS pddr WITH (NOLOCK) ON r.ID = pddr.DeliverableRootID   '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' INNER JOIN dbo.Product_Deliverable AS pd WITH (NOLOCK) ON pd.ID = pddr.ProductDeliverableID  '  
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' INNER JOIN dbo.DeliverableVersion AS v WITH (NOLOCK) ON pd.DeliverableVersionID = v.ID  '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' INNER JOIN dbo.Userinfo as ui WITH (NOLOCK) ON r.DevManagerID = ui.UserId  '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' INNER JOIN dbo.Vendor AS vd WITH (NOLOCK) on vd.ID = v.VendorID  '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' INNER JOIN dbo.DeliverableRoot AS r2 WITH (NOLOCK) ON v.DeliverableRootID = r2.ID  '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' INNER JOIN dbo.ProductVersion AS pv WITH (NOLOCK) ON pd.ProductVersionID = pv.ID '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' INNER JOIN dbo.ProductStatus AS ps WITH (NOLOCK) ON pv.ProductStatusID = ps.ID  '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' INNER JOIN dbo.ProductFamily AS f WITH (NOLOCK) ON pv.ProductFamilyID = f.ID  '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' INNER JOIN dbo.Product_DelRoot AS pr WITH (NOLOCK) ON r.ID = pr.DeliverableRootID AND pv.ID = pr.ProductVersionID '  
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' INNER JOIN dbo.GreenSpec AS gs WITH (NOLOCK) ON v.GreenSpecID = gs.ID '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' INNER JOIN dbo.RoHS AS rh WITH (NOLOCK) ON v.RoHSID = rh.ID   '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' LEFT OUTER JOIN dbo.PilotStatus AS p WITH (NOLOCK) ON p.ID = pd.PilotStatusID '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' LEFT OUTER JOIN dbo.TestStatus AS t WITH (NOLOCK) ON t.ID = pd.TestStatusID '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' LEFT OUTER JOIN dbo.DeliverableCategory_Vendor AS cv WITH (NOLOCK) ON c.ID = cv.DeliverableCategoryID AND  vd.ID = cv.VendorID  '  
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' LEFT OUTER JOIN dbo.Product_DelRoot_Release prr WITH(NOLOCK) ON pr.ID = prr.ProductDelRootID '  
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' LEFT OUTER JOIN dbo.Product_Deliverable_Release pdr WITH(NOLOCK) ON pd.ID = pdr.ProductDeliverableID '  
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' LEFT OUTER JOIN dbo.ProductVersion_Release pvr WITH(NOLOCK) ON pvr.ReleaseID = pdr.ReleaseID and pvr.ProductVersionID = pd.ProductVersionID '  
  
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' LEFT OUTER JOIN dbo.PilotStatus AS p2 WITH (NOLOCK) ON p2.ID = pdr.PilotStatusID '  
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' LEFT OUTER JOIN dbo.ProductVersionRelease pvrelease WITH(NOLOCK) ON pvrelease.ID = pdr.ReleaseID '  
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' LEFT OUTER JOIN dbo.TestStatus tsRelease WITH(NOLOCK) ON pdr.TestStatusID = tsRelease.ID  '   
  SET @SelectFromQuery = @SelectFromQuery   
      + '  WHERE r.RootFilename <> ''HFCN''  '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' AND ((prr.ID is null AND pr.Subassembly <> '''' AND pr.Subassembly is not null) '   
  SET @SelectFromQuery = @SelectFromQuery   
      +   
  ' OR (prr.ID is not null AND prr.Subassembly <> '''' AND prr.Subassembly is not null))'   
  
  IF @FullReport = 1   
  BEGIN   
  SET @SelectFromQuery = @SelectFromQuery   
        +   
  ' and c.commodity=1 and pv.typeid=1 and pv.productstatusid<4'   
  END   
  ELSE   
  BEGIN   
  SET @SelectFromQuery = @SelectFromQuery + ' and r.typeid=1 '   
  END   
  
  IF Isnull(@ChangeType, '') = ''   
  BEGIN   
  SET @SelectFromQuery = @SelectFromQuery   
        +   
  ' and ((isnull(pv.FusionRequirements, 0) = 0 and pd.teststatusid <> 0) or (isnull(pv.FusionRequirements, 0) = 1 and pdr.TestStatusid <> 0)) '  
  END   
  END   
  
  --PRINT @SelectFromQuery   
  
  PRINT 'FromQuery'   
  
  PRINT @Filter   
  
  SET @SelectFromQuery = Isnull(@SelectFromQuery, '')   
     + Isnull(@Filter, '')   
     + Isnull(@HistoryFilter, '')   
  
  --PRINT @SelectFromQuery   
  
  PRINT 'FromQuery1'   
  
  DECLARE @QuerySql NVARCHAR(max)=''   
  
  --IF NOT (@ReportFormat=2         OR @ReportFormat = 3   
  --          OR @ReportFormat=4     OR @ReportFormat=1   
  --          OR @ReportFormat = 5)   
  --  BEGIN   
  PRINT '1'   
  
  SET @QuerySql =   
  'Select distinct pv.ID, ProductName = pv.Dotsname, Dotsname = pv.Dotsname + case isnull(pv.FusionRequirements,0) when 1 then'  
  SET @QuerySql = @QuerySql   
    +   
  ''' - '' + pvrelease.Name else '''' end , ReleaseID = isnull(pvr.ReleaseID,0),pvrelease.ReleaseYear, pvrelease.ReleaseMonth '  
   + @SelectFromQuery   
   +   
  ' order by ProductName, pvrelease.ReleaseYear desc, pvrelease.ReleaseMonth desc'   
  
  DECLARE @TblProduct TABLE   
  (   
  id           INT IDENTITY(1, 1),   
  productid    INT,   
  productname  VARCHAR(max),   
  dotsname     VARCHAR(max),   
  releaseid    INT,   
  releaseyear  INT,   
  releasemonth INT   
  )   
  
  INSERT INTO @TblProduct   
   (productid,   
    productname,   
    dotsname,   
    releaseid,   
    releaseyear,   
    releasemonth)   
  EXECUTE Sp_executesql   
  @QuerySql   
  
  
  DECLARE @ProductIds           NVARCHAR(max) ='',   
  @ProductList          NVARCHAR(max) ='',   
  @ProductReleaseIdList NVARCHAR(max) =''   
  DECLARE @ProductCount INT = 0   
  
  SELECT @ProductCount = Count(id)   
  FROM   @TblProduct   
  
  SELECT @ProductIds = CASE   
      WHEN @ProductIds = '' THEN   
      CONVERT(VARCHAR(50), productid   
      )   
      ELSE @ProductIds + ','   
       + CONVERT(VARCHAR(50), productid)   
      END   
  FROM   @TblProduct   
  
  SELECT @ProductList = CASE   
      WHEN @ProductList = '' THEN dotsname   
      ELSE @ProductList + ',' + dotsname   
      END   
  FROM   @TblProduct   
  
  SELECT @ProductReleaseIdList = CASE   
         WHEN @ProductReleaseIdList = '' THEN   
         CONVERT(VARCHAR(50), productid) + ';'   
         + CONVERT(VARCHAR(50), releaseid)   
         ELSE @ProductReleaseIdList + ','   
          + CONVERT(VARCHAR(50), productid) +   
          ';'   
          + CONVERT(VARCHAR(50), releaseid)   
        END   
  FROM   @TblProduct   
  --END  
    
  SELECT  @PrdCount =  count(DISTINCT dotsname) from @TblProduct  
  if (@PrdCount > @ColumnLimit)  
  begin  
    SET @ErrorMessage = 'Column Limit Exceeded More Than ' + cast(@ColumnLimit as varchar(10)) + ' Columns, Suggest to Select Proper Column Pagination, Available Columns: ' + cast(@PrdCount as varchar(10))  
    RAISERROR(@ErrorMessage,16,1);   
  end  
  
  select * into #ProductInfo from @TblProduct  
  DECLARE @cols AS NVARCHAR(MAX),  
  @query  AS NVARCHAR(MAX)  
  
  
  DECLARE @PVDate  DATETIME,   
  @SI1Date DATETIME,   
  @SI2Date DATETIME   
  
  PRINT '2'   
  
  IF @ProductCount = 1   
  BEGIN   
  SELECT @SI1Date = CASE   
      WHEN schedule_definition_data_id = 18 THEN   
      COALESCE(actual_start_dt, projected_start_dt,   
      por_start_dt)   
      ELSE @SI2Date   
     END,   
   @SI2Date = CASE   
      WHEN schedule_definition_data_id = 25 THEN   
      COALESCE(actual_start_dt, projected_start_dt,   
      por_start_dt)   
      ELSE @SI2Date   
     END,   
   @PVDate = CASE   
      WHEN schedule_definition_data_id = 32 THEN   
      COALESCE(actual_start_dt, projected_start_dt,   
      por_start_dt)   
      ELSE @PVDate   
     END   
  FROM   product_release pr WITH (nolock)   
   INNER JOIN schedule s WITH (nolock)   
     ON s.product_release_id = pr.id   
   INNER JOIN schedule_data sd WITH (nolock)   
     ON sd.schedule_id = s.schedule_id   
  WHERE  pr.productversionid = @ProductIds   
   AND releaseid = 1   
   AND schedule_definition_data_id IN( 18, 25, 32 )   
  END   
  
  SELECT @ProductIds           AS ProductIds,   
  @ProductList          AS Products,   
  @ProductReleaseIdList AS ProductReleaseIds,   
  @PVDate AS PVDate,   
  @SI1Date AS SI1Date,   
  @SI2Date AS SI2Date   
  
   DECLARE @ProductHardwareSearchQuery NVARCHAR(max)   
    
   Declare @randomNo varchar(10);  
   Set @randomNo = Cast(ROUND(RAND() * 100000,0) as varchar(10));  
  
   DECLARE @tmpResult varchar(100)  
  SET @tmpResult = '##Result_' + @randomNo  
  
  IF @ReportFormat = 2   
  BEGIN   
  
  
  SET @ProductHardwareSearchQuery = 'select * ,'''' as SampleDateDesc,cast('''' as varchar(max)) as SI1DateDesc,cast('''' as varchar(max)) as SI2DateDesc,cast('''' as varchar(max)) as SubAssemblyFeatureDesc,'''' as HeaderColor,'''' as ColumnColor,'''' as 
RowColor  
  ,'''' as BGCOLOR,'''' as tdBGColor,'''' as AccessoryBGColor,'''' as EOLBGColor into ' + @tmpResult + ' from (' + Isnull(@SelectFieldQuery, '')   
         + Isnull(@SelectFromQuery, '')   
         + ')result'  
  --'order by c.name, pr.Base, r.id, vd.name, v.id'   
  END   
  ELSE IF @ReportFormat = 5   
  BEGIN   
  
  SET @ProductHardwareSearchQuery = 'SELECT * ,'''' as SampleDateDesc,cast('''' as varchar(max)) as SI1DateDesc,cast('''' as varchar(max)) as SI2DateDesc,cast('''' as varchar(max)) as SubAssemblyFeatureDesc,'''' as HeaderColor,'''' as ColumnColor,'''' as 
RowColor  
  ,'''' as BGCOLOR,'''' as tdBGColor,'''' as AccessoryBGColor,'''' as EOLBGColor INTO ' + @tmpResult + ' FROM (' + Isnull(@SelectFieldQuery, '')   
         + Isnull(@SelectFromQuery, '')    
         +   
  ')result' --' order by c.name, pr.Base, vd.name, v.id'  
  END   
  ELSE IF @ReportFormat=4  
  BEGIN  
  SET @ProductHardwareSearchQuery = 'select * ,'''' as SampleDateDesc,cast('''' as varchar(max)) as SI1DateDesc,cast('''' as varchar(max)) as SI2DateDesc,cast('''' as varchar(max)) as SubAssemblyFeatureDesc,'''' as HeaderColor,'''' as ColumnColor,'''' as 
RowColor  
  ,'''' as BGCOLOR,'''' as tdBGColor,'''' as EOLBGColor into ' +  @tmpResult +' from (' + Isnull(@SelectFieldQuery, '')   
         + Isnull(@SelectFromQuery, '')        
         + ' )result'  
  END  
  ELSE   
  BEGIN   
  SET @ProductHardwareSearchQuery = 'select * ,'''' as SampleDateDesc,cast('''' as varchar(max)) as SI1DateDesc,cast('''' as varchar(max)) as SI2DateDesc,cast('''' as varchar(max)) as SubAssemblyFeatureDesc,'''' as HeaderColor,'''' as ColumnColor,'''' as 
RowColor  
  ,'''' as BGCOLOR,'''' as tdBGColor,'''' as AccessoryBGColor,'''' as EOLBGColor into ' + @tmpResult + ' from (' + Isnull(@SelectFieldQuery, '')   
         + Isnull(@SelectFromQuery, '')    
                                          
         + ' )result' --' order by c.name, r.name, vd.name, v.id' +  
  END   
  
  PRINT 'Result'   
  
  PRINT '----'   
  
    
  EXECUTE Sp_executesql  @ProductHardwareSearchQuery   
    
   /* To Handle the Null columns*/  
  declare @NotNullCols varchar(max)  
   set  @NotNullCols =  
  
    (  
     SELECT 'alter table ' + TABLE_NAME + ' alter column ' + COLUMN_NAME + ' ' + data_type + ' Null;'  
     FROM tempdb.INFORMATION_SCHEMA.COLUMNS  
     WHERE TABLE_SCHEMA = 'dbo'  
     AND TABLE_NAME = @tmpResult  
     AND IS_NULLABLE = 'NO'   
     for xml path(''), type  
     ).value('(./text())[1]','varchar(max)')  
  
   select @NotNullCols = Replace(@NotNullCols,'varchar','varchar(max)')  
    --select @NotNullCols  
     EXEC( @NotNullCols )  
   /* To Handle the Null columns*/  
  
  /*Begin: To handle Global Temp Table*/  
    BEGIN TRANSACTION;  
    exec( 'Select * into ##Result from ' +   @tmpResult + ' where 1=0')  
    select * into #Result from ##Result  
    drop table ##Result  
    COMMIT TRANSACTION;  
  
  INSERT INTO #Result  
  EXEC('Select * from ' +   @tmpResult)  
  EXEC('Drop table ' + @tmpResult)  
  
  /*End: To handle Global Temp Table*/  
  
  print 'Prd Hardware Completed'  
  
  print 'Selection Result'  
    
  print 'Selection Resutl End'  
  Alter table #Result alter column SubAssemblyBaseDesc varchar(max)  
  Alter table #Result alter column FeatureName varchar(max)  
  Alter table #Result alter column DCRDesc varchar(max)  
  Alter table #Result alter column EOLDateDesc varchar(max)  
  Alter table #Result alter column VendorWithSupplier varchar(max)  
  Alter table #Result alter column RohsGreenSpec varchar(max)  
  Alter table #Result alter column PilotStatusDesc varchar(max)  
  Alter table #Result alter column AccessoryStatusDesc varchar(max)  
  Alter table #Result alter column TestStatusDesc varchar(max)  
  Alter table #Result alter column SampleDateDesc varchar(max)  
  Alter table #Result alter column SI1DateDesc varchar(max)  
  Alter table #Result alter column SI2DateDesc varchar(max)  
  Alter table #Result alter column SubAssemblyFeatureDesc varchar(max)  
  Alter table #Result alter column subassembly varchar(max)  
  Alter table #Result alter column subassemblyBase varchar(8000)  
  Alter table #Result add FeatureNameDesc varchar(max)  
  Alter table #Result alter column location varchar(max)  
  alter table #Result alter column AccessoryBGColor varchar(1000);  
  /*subassemblyBase  DeliverableName  FeatureName -Reportformat-2 or 5*/  
  /*RootID -  DeliverableName  strFeatureName -else*/  
  
  DECLARE @cntproduct int = 0  
  set @cntproduct = @PrdCount  
  Print 'Update Start'  
  update #Result set SubAssemblyBaseDesc=case when SubAssemblyBase <>'' then SubAssemblyBase + '-xxx' end,    
  DCRDesc =case WHEN DCRID > 2 THEN 'DCR: '+ DCRDesc   
   WHEN DCRID = 2 THEN  'HFCN'  
   WHEN DCRID = 1 THEN  'POR'  
  ELSE   
  ''  
  END  
  ,EOLDateDesc= CASE WHEN @ReportFormat=5 THEN   
                           CASE WHEN ServiceActive=0 THEN '<div class="factoryEOAColor" style="background-color:'+EOLBGColor+ '">'+ 'Unavailable' + '</div>' ELSE '<div class="factoryEOAColor" style="background-color:'+EOLBGColor+ '">'+ Convert(varchar(max
),ServiceEOADate) + '</div>'  END  
                     ELSE  
                           CASE WHEN Active=0 AND  ServiceActive=1 THEN '<div class="factoryEOAColor" style="background-color:'+EOLBGColor+ '">'+ 'Service Only' + '</div>'  
                           ELSE   
                                  CASE WHEN Active=0 AND  ServiceActive=0 THEN '<div class="factoryEOAColor" style="background-color:'+EOLBGColor+ '">'+ 'Unavailable' + '</div>'  
                                  ELSE   
                                  '<div class="factoryEOAColor" style="background-color:'+EOLBGColor+ '">'+ CASE WHEN EndOfLifeDate IS NOT NULL THEN  Convert(varchar(10),EndOfLifeDate,101) ELSE '' END + '</div>'  
                                  END  
                           END  
                     END  
  ,VendorWithSupplier =  
  CASE WHEN ISNULL(SupplierCode,'')='' OR  SupplierCode='TBD' THEN  
     CONVERT(VARCHAR(MAX),isnull(Vendor,'')) ELSE CONVERT(VARCHAR(MAX),isnull(Vendor,''))   
     + ' (' +  CONVERT(VARCHAR(MAX),supplierCode) +')' END  
  ,RohsGreenSpec =    CASE WHEN ISNULL(Rohs,'')='' AND  ISNULL(GreenSpec,'')='' THEN  '<div class="rohsGreenSpec" style="background-color:Salmon"> </div>'  
       ELSE  
       CASE WHEN ISNULL(Rohs,'')<>'' AND  ISNULL(GreenSpec,'')<>'' THEN   Rohs + '_' + GreenSpec  -- '<div class="rohsGreenSpec" style="background-color:Salmon">'+ Rohs + '_' + GreenSpec +'</div>'  
       ELSE   
       CASE WHEN ISNULL(Rohs,'')<>'' THEN '<div class="rohsGreenSpecYellow" style="background-color:#ffff99">'+ Rohs +'</div>'  
       ELSE   
       '<div class="rohsGreenSpecYellow" style="background-color:#ffff99">'+  GreenSpec +'</div>'   
       END   
       END  
       END,  
              TestStatusDesc= isnull(  
              CASE WHEN @ReportFormat=4 AND ISNULL(commodity,0)=0 THEN   
              'N/A'  
              ELSE  
                     case when (((@ReportFormat=3 OR @ReportFormat=4) AND @cntproduct=1) OR (@ReportFormat<>3 AND @ReportFormat<>4)) THEN   
                                  case when TestStatus ='Date' THEN   
                                                convert(varchar(10),isnull(Testdate,''),120)  
                                         when TestStatus='QComplete' and RiskRelease=1 THEN  
                                                              CASE   
                                                              WHEN (TestStatus = 'Date' OR TestStatus = 'OOC' OR TestStatus = 'FCS') THEN  
                                                                                         CASE   
                                                                                         WHEN TestConfidence = 3 THEN  '<div class="testStatusColor" style="background-color:Salmon">'   
                                                                                         WHEN TestConfidence = 2 THEN  '<div class="testStatusColorYellow" style="background-color:#ffff99">'   
                                                                                         ELSE  
                                                                                                case  MatrixBGColor  
                                                                                                              When 'DarkSeaGreen' then '<div class="testStatusMatrixBGColorDarkSeaGreen" style="background-color:'+LTRIM(RTRIM(LOWER(MatrixBGColor)))+'">'   
                                                                                                              When '#ffff99' then '<div class="testStatusMatrixBGColorYellow" style="background-color:'+LTRIM(RTRIM(LOWER(MatrixBGColor)))+'">'   
                                                                                                              When 'lightsteelblue' then '<div class="testStatusMatrixBGColorlightsteelblue" style="background-color:'+LTRIM(RTRIM(LOWER(MatrixBGColor)))+'">' 
 
                                                                                                END  
                                                                                         END  
                         ELSE   
                                                                                         case  MatrixBGColor  
                                                                                                              When 'DarkSeaGreen' then '<div class="testStatusMatrixBGColorDarkSeaGreen" style="background-color:'+LTRIM(RTRIM(LOWER(MatrixBGColor)))+'">'   
                                                                                                              When '#ffff99' then '<div class="testStatusMatrixBGColorYellow" style="background-color:'+LTRIM(RTRIM(LOWER(MatrixBGColor)))+'">'   
                                                                                                              When 'lightsteelblue' then '<div class="testStatusMatrixBGColorlightsteelblue" style="background-color:'+LTRIM(RTRIM(LOWER(MatrixBGColor)))+'">' 
 
                                                                                         END  
                                                              END   
                                                       + 'Risk Release'  + '</div>'  
                                         when TestStatus= 'Investigating' and (@IsShowTestStep=1 or @IsShowReleaseStep=1)  then   
                                                              case when LEFT([location],9)='core team' THEN  
                                                                                  CASE   
                                                                                         WHEN (TestStatus = 'Date' OR TestStatus = 'OOC' OR TestStatus = 'FCS') THEN  
                                                                                                              CASE   
                                                                                                                           WHEN TestConfidence = 3 THEN  '<div class="testStatusColor" style="background-color:Salmon">'   
                                                                                                                           WHEN TestConfidence = 2 THEN  '<div class="testStatusColorYellow" style="background-color:#ffff99">'   
                                                                                                               ELSE  
                                                                                                                                  case  MatrixBGColor  
                                                                                                                                                When 'DarkSeaGreen' then '<div class="testStatusMatrixBGColorDarkSeaGreen" style="background-color:'+LTRIM(RTRI
M(LOWER(MatrixBGColor)))+'">'   
                                                                                                                                                When '#ffff99' then '<div class="testStatusMatrixBGColorYellow" style="background-color:'+LTRIM(RTRIM(LOWER(Mat
rixBGColor)))+'">'   
                                                                                                                                                When 'lightsteelblue' then '<div class="testStatusMatrixBGColorlightsteelblue" style="background-color:'+LTRIM(
RTRIM(LOWER(MatrixBGColor)))+'">'  
                                                                                                                                  END  
                                                                                                              END  
                                                                                         END  
                                                                
                                                                           + 'Core Team'+ '</div>'  
                                                                     when LEFT([location],11)='engineering' OR LEFT([location],8)='eng. dev' THEN   
                                                       CASE   
                                                                                  WHEN (TestStatus = 'Date' OR TestStatus = 'OOC' OR TestStatus = 'FCS') THEN  
                                                                                                              CASE   
                                                                                                                     WHEN TestConfidence = 3 THEN  '<div class="testStatusColor" style="background-color:Salmon">'   
                                                                                                                     WHEN TestConfidence = 2 THEN  '<div class="testStatusColorYellow" style="background-color:#ffff99">'   
                                                                                                              ELSE   
                                                                                                                     case WHEN MatrixBGColor IS NULL then '<div class="testStatusEmpty">'  
                                                                                                                     ELSE  
                                                                                                                           case  MatrixBGColor  
                                                                                                                                         When 'DarkSeaGreen' then '<div class="testStatusMatrixBGColorDarkSeaGreen" style="background-color:'+LTRIM(RTRIM(LOWER
(MatrixBGColor)))+'">'   
                                                                                                                                         When '#ffff99' then '<div class="testStatusMatrixBGColorYellow" style="background-color:'+LTRIM(RTRIM(LOWER(MatrixBGCo
lor)))+'">'   
                                                                                                                                         When 'lightsteelblue' then '<div class="testStatusMatrixBGColorlightsteelblue" style="background-color:'+LTRIM(RTRIM(L
OWER(MatrixBGColor)))+'">'  
                                                                                                                           END  
                                                                                                                     END   
                                                                                                              END  
                                                                
                                                                                  END   
                                                                            + 'Engineering'+ '</div>'  
                                                                     ELSE   
                                                                                  CASE   
                                                                                  WHEN (TestStatus = 'Date' OR TestStatus = 'OOC' OR TestStatus = 'FCS') THEN  
                                                                                                              CASE   
                                                                                                                     WHEN TestConfidence = 3 THEN  '<div class="testStatusColor" style="background-color:Salmon">'   
                                                                                                                     WHEN TestConfidence = 2 THEN  '<div class="testStatusColorYellow" style="background-color:#ffff99">'   
                                                                                                              ELSE   
                                                                                                                     case  when MatrixBGColor is null then '<div class="testStatusEmpty">'   
                                                                                            else   
                                                                                                                                  case MatrixBGColor   
                                                                                                                                                When 'DarkSeaGreen' then '<div class="testStatusMatrixBGColorDarkSeaGreen" style="background-color:'+LTRIM(RTRI
M(LOWER(MatrixBGColor)))+'">'   
                                                                                                                                                When '#ffff99' then '<div class="testStatusMatrixBGColorYellow" style="background-color:'+LTRIM(RTRIM(LOWER(Mat
rixBGColor)))+'">'   
                                                                                                                                                When 'lightsteelblue' then '<div class="testStatusMatrixBGColorlightsteelblue" style="background-color:'+LTRIM(
RTRIM(LOWER(MatrixBGColor)))+'">'  
                                                                                                                                  END  
                                                                                                                     END  
                                                                                                              END  
                                                                
                                                                                  END   
                                                                     +'Investigating'+ '</div>'  
                                                                END  
                                           
                                         WHEN (@ReportFormat = 0 OR @ReportFormat=1 OR @ReportFormat=2 OR @ReportFormat=3) and LOWER(TestStatus)='service only' THEN  
                                                       CASE   
                                                              WHEN (TestStatus = 'Date' OR TestStatus = 'OOC' OR TestStatus = 'FCS') THEN  
                                                                                  CASE   
                                                                                                WHEN TestConfidence = 3 THEN  '<div class="testStatusColor" style="background-color:Salmon">'   
                                                                                                WHEN TestConfidence = 2 THEN  '<div class="testStatusColorYellow" style="background-color:#ffff99">'   
                                                                                         ELSE   
                                                                                                case  when MatrixBGColor is null then '<div class="testStatusEmpty">'   
                                                                                                else   
                                                                                                       case MatrixBGColor  
                                                                                                              When 'DarkSeaGreen' then '<div class="testStatusMatrixBGColorDarkSeaGreen" style="background-color:'+LTRIM(RTRIM(LOWER(MatrixBGColor)))+'">'   
                                                                                                              When '#ffff99' then '<div class="testStatusMatrixBGColorYellow" style="background-color:'+LTRIM(RTRIM(LOWER(MatrixBGColor)))+'">'   
                                                                                                              When 'lightsteelblue' then '<div class="testStatusMatrixBGColorlightsteelblue" style="background-color:'+LTRIM(RTRIM(LOWER(MatrixBGColor)))+'">' 
 
                           END  
                                                                                                END  
                                                                                         END  
                                                                
                                                       END +  'Dropped'+ '</div>'  
                                  ELSE  
                                  --isnull(TestStatus,'')  
                                         case when  MatrixBGColor is null then  '<div class="testStatusEmpty">'+ isnull(TestStatus,'') +'</div>'  
                                         else   
                                                case MatrixBGColor When 'DarkSeaGreen' then '<div class="testStatusMatrixBGColorDarkSeaGreen" style="background-color:'+LTRIM(RTRIM(LOWER(MatrixBGColor)))+'">' + isnull(TestStatus,'') +'</div>'  
                                                                              When '#ffff99' then '<div class="testStatusMatrixBGColorYellow" style="background-color:'+LTRIM(RTRIM(LOWER(MatrixBGColor)))+'">' + isnull(TestStatus,'') +'</div>'  
                                                                              When 'lightsteelblue' then '<div class="testStatusMatrixBGColorlightsteelblue" style="background-color:'+LTRIM(RTRIM(LOWER(MatrixBGColor)))+'">' + isnull(TestStatus,'') +'</div>
'  
                                                END  
                                         --'<div class="testStatusMatrixBGColor" style="background-color:'+LTRIM(RTRIM(LOWER(MatrixBGColor)))+'">' + isnull(TestStatus,'') +'</div>'  
                                         END  
                                  END  
                                  END  
                                  END,''),  
 --New update columns are below - 25072018 - TestStatusDisplay Issue Fixed  
   SampleDateDesc=CASE WHEN @PVDate='' OR (NOT ISDATE(@PVDate)=1) THEN 'N/A'   
                                                     WHEN SampleDate='' OR (NOT ISDATE(SampleDate)=1) THEN  'UnKnown'  
                                                     WHEN DATEDIFF(DD,@PVDate,SampleDate) <=0 THEN   
                                                             CONVERT(VARCHAR(10),DATEDIFF(DD,@PVDate,SampleDate)) +' Days Early'  
                                                     ELSE  
                                                            CONVERT(VARCHAR(10),DATEDIFF(DD,@PVDate,SampleDate)) +' Days Late'  
                                           END,  
              SI1DateDesc=        CASE WHEN @SI1Date='' OR (NOT ISDATE(@SI1Date)=1) THEN 'N/A'   
                                                     WHEN SampleDate='' OR (NOT ISDATE(SampleDate)=1) THEN  'UnKnown'  
                                                     WHEN DATEDIFF(DD,@SI1Date,SampleDate) <=0 THEN   
                                                             CONVERT(VARCHAR(10),DATEDIFF(DD,@SI1Date,SampleDate)) +' Days Early'  
                                                     ELSE  
                                                            CONVERT(VARCHAR(10),DATEDIFF(DD,@SI1Date,SampleDate)) +' Days Late'  
                                           END,  
                SI2DateDesc=CASE WHEN @SI2Date='' OR (NOT ISDATE(@SI2Date)=1) THEN 'N/A'   
                                                     WHEN SampleDate='' OR (NOT ISDATE(SampleDate)=1) THEN  'UnKnown'  
                                                     WHEN DATEDIFF(DD,@SI2Date,SampleDate) <=0 THEN   
                                                             CONVERT(VARCHAR(10),DATEDIFF(DD,@SI2Date,SampleDate)) +' Days Early'  
                                                     ELSE  
                                                            CONVERT(VARCHAR(10),DATEDIFF(DD,@SI2Date,SampleDate)) +' Days Late'  
                                           END,  
                    SubAssemblyFeatureDesc =   
                    CASE WHEN @ReportFormat=2 AND CategoryId=227 THEN  
                           SubAssemblyBase + '[' + DeliverableName + '] ' + '('+ FeatureName + ')'  
                    ELSE  
                    CASE WHEN @ReportFormat=2 OR @ReportFormat=5 THEN  
                                                                   CASE WHEN NOT (CategoryId=227 AND @ReportFormat=2) THEN  
                                                                            SubAssemblyBase + '[' + DeliverableName + '] ' + '('+ FeatureName + ')'   
                                                                   END  
                                                            ELSE  
                                                            CONVERT(VARCHAR(50),RootId) + ' - ' + DeliverableName + (CASE WHEN ISNULL(@ProductIds,'')='' THEN   
                                 CASE WHEN ISNULL(@FamilyIds,'')<>'' AND ISNULL(FusionRequirements,0)=0 THEN   
                                 ''  
                                 ELSE  
                                 CASE WHEN ISNULL(FeatureName,'')='' THEN '(Not Linked)'   
                                 ELSE  ' ( ' + FeatureName +' ) ;'   
                                 END  
                                 END    
                                 ELSE   
                                 CASE WHEN ISNULL(FusionRequirements,0)=1 THEN   
                                 CASE WHEN ISNULL(FeatureName,'')=''  THEN '(Not Linked)'   
                                 ELSE  ' ( ' + FeatureName +' ) '   
                                 END   
                                 ELSE   
                                 ''  
                                 END  
                                 END)  
                    END  
                    END  
     if @ReportFormat=3  
     BEGIN  
     DECLARE @PilotColor VARCHAR(50)  
    SELECT  
    @PilotColor = CASE   
         WHEN @FileType <> '' AND LTRIM(RTRIM(LOWER(PilotBGColor))) = 'darkseagreen' THEN 'SeaGreen'  
         WHEN @FileType <> '' AND LTRIM(RTRIM(LOWER(PilotBGColor))) = 'lightsteelblue' THEN 'LightSkyBlue'  
        END  
    FROM #Result R  
    WHERE @ReportFormat = 3   
     update #Result set PilotStatusDesc=case when @ReportFormat=3 THEN   
       case when PilotStatus ='P_Scheduled' THEN   
       Convert(varchar(max),PilotDate)   
       else  '<div class="pilotColor" style="background-color:'+isnull(@PilotColor,'')+ '">'+ isnull(PilotStatus,'') + '</div>'  
       END  
       END where @ReportFormat=3  
     END   
     if @ReportFormat=4  
     BEGIN  
       DECLARE @AccessoryColor VARCHAR(50)  
    SELECT   
    @AccessoryColor = CASE   
         WHEN @FileType <> '' AND LTRIM(RTRIM(LOWER(AccessoryBGColor))) = 'darkseagreen' THEN 'SeaGreen'  
         WHEN @FileType <> '' AND LTRIM(RTRIM(LOWER(AccessoryBGColor))) = 'lightsteelblue' THEN 'LightSkyBlue'  
        END  
    FROM #Result R where @ReportFormat=4  
       update #Result set AccessoryStatusDesc=case when @ReportFormat=4 THEN   
       case when AccessoryStatus ='Scheduled' THEN   
       Convert(varchar(max),AccessoryDate) else '<div class="accessoryColor" style="background-color:'+ISNULL(@AccessoryColor,'')+ '">'+ ISNULL(AccessoryStatus,'') + '</div>'    
       END  
       END  
     END  
  
  
     Print 'Update Completed'  
      
 /*     
 /* Column Pagination for products 31/07/2018 */  
    
   Declare @ColumnLimit int = 500  
   Declare @PrdCount int  
  
   SELECT  @PrdCount =  count(DISTINCT dotsname) from @TblProduct  
  
   SELECT  DISTINCT dotsname from @TblProduct  
  
   select 'Product count',@PrdCount  
    IF @ColumnPageSize > 0  and @ColumnPageSize < @ColumnLimit  
    BEGIN   
    SELECT  @cols= COALESCE(@cols +', ', '')+ QUOTENAME(dotsname)   
    FROM (  
          SELECT  DISTINCT dotsname from @TblProduct  
        ORDER BY dotsname  
        OFFSET @ColumnPageSize * (@ColumnPageNo - 1) ROWS  
        FETCH NEXT @ColumnPageSize ROWS ONLY  
       )R   
  
       select 'Page count Selected',@ColumnPageSize,@ColumnPageNo  
       SELECT  DISTINCT dotsname from @TblProduct  
        ORDER BY dotsname  
        OFFSET @ColumnPageSize * (@ColumnPageNo - 1) ROWS  
        FETCH NEXT @ColumnPageSize ROWS ONLY  
  
   END  
   ELSE  
   BEGIN  
     Declare @ErrorMessage varchar(100)  
  
    if (@PrdCount > @ColumnLimit)  
    begin  
      SET @ErrorMessage = 'Column Limit Exceeded More Than ' + cast(@ColumnLimit as varchar(10)) + ' Columns, Suggest to Select Proper Column Pagination, Available Columns: ' + cast(@PrdCount as varchar(10))  
      --RAISERROR(@ErrorMessage,16,1);   
    end  
    if (@ColumnPageSize > @ColumnLimit)  
    begin  
     SET @ErrorMessage = 'Column Limit: ' + cast(@ColumnLimit as varchar(10)) + ' Available Columns: ' + cast(@PrdCount as varchar(10)) + ' Columns, Suggest to Select Proper Column Pagination'  
    end  
    set @ColumnPageSize = @ColumnLimit  
    set @ColumnPageNo = 1  
  
    SELECT  @cols= COALESCE(@cols +', ', '')+ QUOTENAME(dotsname)   
    FROM (  
         SELECT DISTINCT dotsname FROM @TblProduct   
         ORDER BY dotsname  
      OFFSET @ColumnPageSize * (@ColumnPageNo - 1) ROWS  
      FETCH NEXT @ColumnPageSize ROWS ONLY  
         )R   
   END  
  
   --Declare @PrdCount varchar(100)  
   --Select  @PrdCount  
    /* Column Pagination for products 31/07/2018 */  
    */  
      
  SELECT  @cols= COALESCE(@cols +', ', '')+ QUOTENAME(dotsname)   
  FROM (SELECT DISTINCT dotsname FROM @TblProduct)R   
    
  print 'Updated Completed'  
  
  
  IF @Type = 1   
  BEGIN   
  create index IX_test_Result_subassemblybase on #Result(subassemblybase)  
  create index IX_test_Result_Categoryid on #Result(Categoryid)  
  CREATE NONCLUSTERED INDEX [Ix_Result_NativeSubassemblyRootID] ON [dbo].[#Result] ([NativeSubassemblyRootID])  
  
    /*Begin:Included New Logic for SubAssembly procedures*/  
  
  /*Begin:spListSubassembliesForBase*/  
  create table #ListSubassembliesForBase(Subassembly varchar(100),  
           SubassemblySpin varchar(20),  
           ProductVersionID int,  
           ReleaseID int)  
  
  create table #ListSubassembliesForRoot(Subassembly varchar(100),  
         SubassemblySpin varchar(20),  
         ProductVersionID int  
         )  
     /*Begin: Modified on 09/08/2018*/  
  IF @ReportFormat = 2 OR @ReportFormat = 5  
  BEGIN  
   if   (@ReportFormat = 2)   
    begin  
     /*Included on 13/07*/  
     select  subassemblyBase   
     into #tsb  
     from #Result where categoryid <>227 and isnull(subassemblyBase,'') <> ''  
     group by category, subassemblyBase, RootID, Vendor, DeliverableVersionID  --Modified on 6/8/2018  
     --select  max(subassemblyBase)  
     ----into #tsb  
     --from #Result where categoryid <>227 and isnull(subassemblyBase,'') <> ''  
     --group by rootid  
  
     create index ix_temp_tsb_subassemblyBase on #tsb(subassemblyBase)  
  
     SELECT    
      DISTINCT CASE   
          WHEN product_delroot_release.id IS NULL THEN   
          pr.subassembly   
          ELSE product_delroot_release.subassembly   
         END AS Subassembly ,   
         CASE   
          WHEN product_delroot_release.id IS NULL   
          THEN   
           pr.spin   
          ELSE product_delroot_release.spin   
          END AS SubassemblySpin,   
       pr.productversionid,   
       pr.deliverablerootid,  
       ReleaseID = Isnull(product_delroot_release.releaseid, 0)   
     INTO #TMP1  
     FROM   product_delroot pr WITH (nolock)   
     LEFT OUTER JOIN product_delroot_release WITH(nolock) ON product_delroot_release.productdelrootid = pr.id   
     left outer join #tsb A on A.subassemblybase = pr.base  
     left outer join #tsb b on B.subassemblybase = product_delroot_release.base  
     WHERE  ( product_delroot_release.id IS NULL --Changed on 12/07/2018  
      --AND pr.base =  @Base)   
      --AND pr.base IN (select distinct subassemblyBase from #Result where categoryid <>227 and isnull(subassemblyBase,'') <> '' )  
      AND A.subassemblybase IS NOT NULL  
      )--Table Name to be changed  
     OR ( product_delroot_release.id IS NOT NULL   
      --AND product_delroot_release.base = @Base)   
      --AND product_delroot_release.base IN (select distinct subassemblyBase from #Result where  categoryid <> 227 and isnull(subassemblyBase,'') <> '')  
      AND B.subassemblybase IS NOT NULL  
      )  
     /*Included on 13/07*/  
       
     
      insert into #ListSubassembliesForBase   
      SELECT DISTINCT   
       pr.Subassembly,  
       pr.SubassemblySpin,  
       pd.ProductVersionID,  
       pr.ReleaseID  
      --INTO #ListSubassembliesForBase --Temp Table  
      FROM ProdDel_DelRoot pdr WITH (NOLOCK)  
      INNER JOIN product_deliverable pd WITH (NOLOCK)   
      ON pd.id = pdr.productdeliverableid  
      INNER JOIN deliverableroot r WITH (NOLOCK)   
      ON r.id = pdr.DeliverableRootID   
      INNER JOIN #TMP1 pr   
      ON pr.productversionid = pd.productversionid   
      and r.id = pr.deliverablerootid  
  
      if object_id('tempdb..#TMP1') is not null DROP TABLE #TMP1  
    end -- c  
   --END  
   ELSE IF @ReportFormat = 5   
   BEGIN  
    /**Begin:SubassembliesForBaseService*/  
    SELECT DISTINCT   
     pr.productversionid,  
     pr.deliverablerootid,  
     CASE WHEN Product_DelRoot_Release.ID is null   
     THEN isnull(pr.ServiceSubassembly,pr.Subassembly)   
     ELSE isnull(Product_DelRoot_Release.ServiceSubassembly,Product_DelRoot_Release.Subassembly) END AS Subassembly,   
     CASE WHEN Product_DelRoot_Release.ID is null   
     THEN isnull(pr.ServiceSpin,pr.Spin)   
     ELSE isnull(Product_DelRoot_Release.ServiceSpin,Product_DelRoot_Release.Spin) END AS SubassemblySpin,  
     ReleaseID = isnull(Product_DelRoot_Release.ReleaseID,0)  
    INTO #TMP2  
    FROM product_delRoot pr WITH (NOLOCK)  
    LEFT OUTER JOIN Product_DelRoot_Release WITH(NOLOCK) ON Product_DelRoot_Release.ProductDelRootID = pr.ID  
    WHERE   
    (Product_DelRoot_Release.ID is null and   
    (pr.Servicebase in (select  subassemblyBase from #Result where isnull(subassemblyBase,'') <>'' group by category, subassemblyBase, Vendor, DeliverableVersionID  ) or ( pr.Servicebase  is null and pr.base in (select  subassemblyBase from #Result where 
isnull(subassemblyBase,'') <>'' group by category, subassemblyBase, Vendor, DeliverableVersionID )))) or   
    (Product_DelRoot_Release.ID is not null and   
    (Product_DelRoot_Release.Servicebase in (select  subassemblyBase from #Result where isnull(subassemblyBase,'') <>'' group by category, subassemblyBase, Vendor, DeliverableVersionID ) or   
    ( Product_DelRoot_Release.Servicebase  is null and Product_DelRoot_Release.base in (select  subassemblyBase from #Result where isnull(subassemblyBase,'') <>'' group by category, subassemblyBase, Vendor, DeliverableVersionID ))))  
  
   insert into #ListSubassembliesForBase   
    SELECT DISTINCT   
     pr.Subassembly,  
     pr.SubassemblySpin,  
     pd.ProductVersionID,  
     pr.ReleaseID  
    --INTO #ListSubassembliesForBase --Temp Table to be chagned   
    FROM ProdDel_DelRoot pdr WITH (NOLOCK)  
    INNER JOIN product_deliverable pd WITH (NOLOCK) ON pd.id = pdr.productdeliverableid  
    INNER JOIN deliverableroot r WITH (NOLOCK) ON r.id = pdr.DeliverableRootID   
    INNER JOIN #TMP2 pr ON pr.productversionid = pd.productversionid and r.id = pr.deliverablerootid  
      
    if object_id('tempdb..#TMP2') is not null DROP TABLE #TMP2   
    /*End:SubassembliesForBaseService*/  
     END  
  END  
  /*End:spListSubassembliesForBase*/  
    
  /*Begin:spListSubassembliesForRoot */  
  if @Reportformat = 2  and exists( select rootid from #Result where categoryid = 227 )  
  BEGIN  
   insert into #ListSubassembliesForRoot  
   Select Distinct pr.Subassembly, pr.Spin as SubassemblySpin, pd.ProductVersionID  
   --into #ListSubassembliesForRoot  
   from ProdDel_DelRoot pdr with (NOLOCK), product_deliverable pd with (NOLOCK), deliverableroot r with (NOLOCK), product_delRoot pr with (NOLOCK)  
   where r.id in (select  rootid from #Result where categoryid = 227 and isnull(rootid,'') <> '' group by category, subassemblyBase, RootID, Vendor, DeliverableVersionID)  
   and pd.id = pdr.productdeliverableid  
   and r.id = pdr.DeliverableRootID  
   and r.id = pr.deliverablerootid  
   and pr.productversionid = pd.productversionid   
  /*End:spListSubassembliesForRoot */  
  END  
  /**/  
  CREATE TABLE [dbo].[#NativeSubAssemblyBase](  
   [NativeSubassembly] [varchar](10) NULL,  
   [deliverablerootid] [int] NOT NULL,  
   [ProductVersionID] [int] NOT NULL  
    )   
    
  if @Reportformat = 2 or @Reportformat = 5  
  begin  
   insert into #NativeSubAssemblyBase  
   --Select pd.base as NativeSubassembly,deliverablerootid,pd.ProductVersionID  
   --from product_delroot pd WITH (NOLOCK), productversion v WITH (NOLOCK)  
   --where pd.deliverablerootid in (select distinct NativeSubassemblyRootID from #Result)  
   --and pd.ProductVersionID in (select distinct ProductVersionID from #Result)  
   --and v.id = pd.productversionid  
   --and pd.base is not null  
   Select   
              pd.base as NativeSubassembly,pd.deliverablerootid,pd.ProductVersionID  
     from product_delroot pd WITH (NOLOCK)  
     inner join #Result r on r.ProductVersionID = pd.ProductVersionID    
     inner join ProductVersion pv on pv.id = r.ProductVersionID   
     where r.NativeSubassemblyRootID = pd.deliverablerootid  
     and pd.base is not null  
     and ISNULL(pv.FusionRequirements,0) = 0  
     union  
     Select   
      pdr.base as NativeSubassembly,pd.deliverablerootid,pd.ProductVersionID  
     from product_delroot pd WITH (NOLOCK)  
     inner join product_delroot_release pdr WITH (NOLOCK) on pdr.ProductDelRootID = pd.ID  
     inner join #Result r on r.ProductVersionID = pd.ProductVersionID    
     inner join ProductVersion pv on pv.id = r.ProductVersionID   
     where  r.NativeSubassemblyRootID = pd.deliverablerootid  
     and pdr.base is not null  
     and pdr.ReleaseID = r.ReleaseID  
     and ISNULL(pv.FusionRequirements,0) = 1  
  
  end  
 /*End: Modified on 09/08/2018*/  
  
  
  update #Result set  
     FeatureNameDesc =   
  CASE WHEN @ReportFormat=2 or @ReportFormat=5 THEN   
     cast(ISNULL(SubAssemblyBase,'') as varchar(1000)) + '[' + ISNULL(DeliverableName,'') + ']'  + '( ' +  ISNULL(FeatureName,'') + ')'  
  ELSE  
     (cast(ISNULL(RootId,'') as varchar(1000)) + ' - ' +  '[' + ISNULL(DeliverableName,'') + ']'   +   
     CASE WHEN ISNULL(@Products,'')='' THEN   
      CASE WHEN ISNULL(@FamilyIds,'')<>'' AND ISNULL(FusionRequirements,0)=0 THEN   
      ''  
      ELSE  
       CASE WHEN ISNULL(FeatureName,'')='' THEN '(Not Linked)'   
       ELSE  ' ( ' + FeatureName +' ) '   
       END  
      END    
     ELSE   
     CASE WHEN ISNULL(FusionRequirements,0)=1 THEN   
      CASE WHEN ISNULL(FeatureName,'')='' THEN '(Not Linked)'   
        ELSE  '( ' + FeatureName +' ) '   
      END   
     ELSE   
     ''  
     END  
  END  
  )  
  END  
   
  
  /* Union Query */    
   alter table #Result add NativeSubassembly varchar(50) null  
   alter table #Result add GroupHeader int   
  
   --select * from #Result  
   update r  
   set NativeSubassembly = b.NativeSubassembly,GroupHeader = 3  
   from #Result r  
   left join #NativeSubAssemblyBase b on r.NativeSubassemblyRootID = b.deliverablerootid and r.ProductVersionID = b.ProductVersionID  
  
    -- alter table #Result1 alter column Deliverableversionid int  null  
  /*Begin: Modified on 09/08/2018*/  
  if @ReportFormat <> 2 and @ReportFormat <> 5 --Mod on 09/08/2018  
  begin  
   update B  
   set FeatureNameDesc = FN  
   from #Result B  
   inner join  
   (select   
    rootid,min(FeatureNameDesc) FN  
   from #Result  
   group by rootid) A on A.rootid = B.rootid  
  end  
  
 if @ReportFormat = 2 or @ReportFormat = 5 --Mod on 09/08/2018  
  begin  
   update B  
   set subassemblybaseDesc = FN  
   from #Result B  
   inner join  
   (select   
    subassemblybase,min(subassemblybaseDesc) FN  
   from #Result  
   group by subassemblybase) A on A.subassemblybase = B.subassemblybase  
  end  
  /*End: Modified on 09/08/2018*/  
  
   insert into #Result(GroupHeader,location,SubAssemblyBaseDesc,subassemblySpin,Dotsname,FeatureNameDesc,category)  
   select distinct 2 as GroupHeader,  
    FeatureNameDesc as location,  
    SubAssemblyBaseDesc,  
    b.subassemblySpin,  
    r.Dotsname as Dotsname,--  
    FeatureNameDesc as FeatureNameDesc,  
    category  
    from #ListSubassembliesForBase b  
    inner join (select distinct   
    productversionid,releaseid,Dotsname,FeatureNameDesc,SubAssemblyBaseDesc,category  
    from #Result)  r on r.productversionid = b.productversionid and r.releaseid = b.releaseid  
  
   union  
      /*#ListSubassembliesForRoot*/  
   select distinct 2 as GroupHeader,  
    FeatureNameDesc as location,  
    SubAssemblyBaseDesc,  
    b.subassemblySpin,  
    r.Dotsname as Dotsname,--  
    FeatureNameDesc as FeatureNameDesc,  
    category  
   from #ListSubassembliesForRoot b  
   inner join (select distinct   
    productversionid,releaseid,Dotsname,FeatureNameDesc,SubAssemblyBaseDesc,category  
    from #Result) r on r.productversionid = b.productversionid  
  
   alter table #Result alter column HeaderColor varchar(1000);  
   alter table #Result alter column ColumnColor varchar(1000);  
   alter table #Result alter column RowColor varchar(1000);  
   alter table #Result alter column BGCOLOR varchar(1000);  
   alter table #Result alter column tdBGColor varchar(1000);  
   --alter table #Result alter column AccessoryBGColor varchar(1000);  
   alter table #Result alter column EOLBGColor varchar(1000);  
   alter table #Result add FeatureNameDescDisplay varchar(max)  
  
  PRINT 'UNION END'  
  /* The below query should be corrected*/  
     /*if request("ReportFormat") = "2" or request("ReportFormat") = "5" then  
     TR bgcolor=Burlywood*/  
       
  
      
     --if Request("ReportFormat")="5" then  
     --if isnull(rs("ServiceEOADate")) and rs("ServiceActive") then  
     
     UPDATE  R /* Line 1173*/  
     SET EOLBGColor = case   
          when ServiceEOADate is null and ServiceActive = 1 then ''   
          when datediff(day,ServiceEOADate,getdate()) >= -120 and datediff(day,ServiceEOADate,getdate()) < 0 then '#ffff99'  
          when datediff(day,ServiceEOADate,getdate()) > 0 and ServiceActive != 1 then 'salmon'  
          else ''  
         end  
     FROM #Result R  
     WHERE @ReportFormat = 5  
     /* else part 1379 */  
       UPDATE  R   
     SET EOLBGColor =   
         case   
          when EOLDate is null and Active=1 then EOLBGColor  
          when datediff(day,EndOfLifeDate,getdate()) >= -120 and datediff(day,EndOfLifeDate,getdate()) < 0 then '#ffff99'  
          when datediff(day,EOLDate,getdate()) > 0 and Active != 1 then 'salmon'  
          else ''  
         end  
     FROM #Result R  
     WHERE @ReportFormat != 5  
       
     --if  instr("," & replace(request("HighlightRow")," ","") & ",","," & trim(rs("Deliverableversionid")) & ",") > 0 then  
  
       
  
    --DECLARE @PilotColor VARCHAR(50)  
    ----if request("FileType") <> "" and strpilotcolor = "darkseagreen" then  
    --SELECT/* TD Line number 1537*/  
    --@PilotColor = CASE   
    --     WHEN @FileType <> '' AND LTRIM(RTRIM(LOWER(PilotBGColor))) = 'darkseagreen' THEN 'SeaGreen'  
    --     WHEN @FileType <> '' AND LTRIM(RTRIM(LOWER(PilotBGColor))) = 'lightsteelblue' THEN 'LightSkyBlue'  
    --    END  
    --FROM #Result R  
    --WHERE @ReportFormat = 3 --CONDITION TO BE ADDED  
  
    --DECLARE @AccessoryColor VARCHAR(50)  
    ----if request("FileType") <> "" and strpilotcolor = "darkseagreen" then  
    --SELECT /* TD Line number 1537*/  
    --@AccessoryColor = CASE   
    --     WHEN @FileType <> '' AND LTRIM(RTRIM(LOWER(AccessoryBGColor))) = 'darkseagreen' THEN 'SeaGreen'  
    --     WHEN @FileType <> '' AND LTRIM(RTRIM(LOWER(AccessoryBGColor))) = 'lightsteelblue' THEN 'LightSkyBlue'  
    --    END  
    --FROM #Result R  
    --WHERE @ReportFormat = 4 --CONDITION TO BE ADDED  
  
    /* LINE 1581 */  
    --if ((request("ReportFormat") = "3" or request("ReportFormat") = "4") and productCount = 1) or (request("ReportFormat") <> "3" and request("ReportFormat") <> "4") then  
    DECLARE @TestColor VARCHAR(50)  
  
    SELECT /* TD Line number 1537*/  
    @TestColor = CASE   
         WHEN (TestStatus = 'Date' OR TestStatus = 'OOC' OR TestStatus = 'FCS') THEN  
           CASE   
             WHEN TestConfidence = 3 THEN 'salmon'  
             WHEN TestConfidence = 2 THEN '#ffff99'  
             ELSE LTRIM(RTRIM(LOWER(MatrixBGColor)))  
           END  
           
        END  
    FROM #Result R  
    WHERE (((@ReportFormat = 3 OR @ReportFormat = 4) AND @cntproduct = 1) OR (@ReportFormat <> 3 AND @ReportFormat <> 4))  
     
    SELECT /* TD Line number 1537*/  
    @TestColor =   
       CASE   
        WHEN @FileType <> '' AND @TestColor = 'darkseagreen' THEN 'SeaGreen'  
        WHEN @FileType <> '' AND @TestColor = 'lightsteelblue' THEN 'LightSkyBlue'  
  
       END  
    FROM #Result R  
    WHERE (((@ReportFormat = 3 OR @ReportFormat = 4) AND @cntproduct = 1) OR (@ReportFormat <> 3 AND @ReportFormat <> 4))  
  
      
    SELECT  
    @TestColor =  CASE WHEN commodity=0 or commodity IS NULL  THEN '' END  
    FROM #Result R  
    WHERE @ReportFormat = 4  
  
      
  
     
    alter table #Result alter column Bridged varchar(400) null  
 /*End: Coloring Logic */  
  update #Result set Bridged =case when RootId=nativeSubAssemblyRootId then '' else ISNULL(NativeSubAssembly,'UnKnown') end  
  
  
  --/* to Remove  
  Declare @randomNumber varchar(10);  
  Set @randomNumber = Cast(ROUND(RAND() * 100000,0) as varchar(10));  
  
  
  DECLARE @tmpHardwareMatrixReport varchar(MAX)  
  SET @tmpHardwareMatrixReport = '##HardwareMatrixReport_' + @randomNumber  
  
  DECLARE @tmpHardwareMatrixPivot varchar(100)  
  SET @tmpHardwareMatrixPivot = '##HardwareMatrixPivot_' + @randomNumber  
  
  DECLARE @tmpHardwareMatrixSubAssemblyPivot varchar(100)  
  SET @tmpHardwareMatrixSubAssemblyPivot = '##HardwareMatrixSubAssemblyPivot_' + @randomNumber  
  
    /* Included on 05/07/2018*/  
  --update R1  
  --set  TestStatusDesc = NULL  
  --from #Result R1  
  --where productversionid not in (select substring(value,0,charindex(';',value)) as Productversionid  
  --                                 from dbo.ufn_split(@ProductReleaseIdList,','))  
  --   OR Releaseid not in (select substring(value,charindex(';',value)+1,len(value)) as Releaseid  
  --   from dbo.ufn_split(@ProductReleaseIdList,','))  
  /* Included on 05/07/2018*/  
  
    
  
 /*Begin: Pivot for Product with Status*/  
  if @cols is not null  
  begin  
   declare @pivotfield VARCHAR(MAX)  
  
   IF @ReportFormat = 4  
   BEGIN  
   SET @pivotfield = 'AccessoryStatusDesc'  
   END  
   ELSE if @ReportFormat = 3  
   BEGIN  
   SET @pivotfield = 'PilotStatusDesc'  
   END  
   ELSE   
   BEGIN  
   SET @pivotfield = 'TestStatusDesc'  
   END  
   EXEC (';WITH PIVOT_DATA AS  
   (  
   select distinct  
     category as category ,  
     deliverableversionid,  
     p.Dotsname as DotsNameDesc,  
     subassemblybase,  
     ' + @pivotfield + '   
   from #Result r  
   left join #ProductInfo p on p.productid = r.productversionid and p.releaseid=r.releaseid  
   where deliverableversionid is not null   
   and category is not null and subassemblybase is not null  
   group by   
     category,  
     deliverableversionid,  
     p.Dotsname,  
     subassemblybase,  
     ' + @pivotfield + '   
   ) SELECT *  
   INTO  ' + @tmpHardwareMatrixPivot + '  
   FROM PIVOT_DATA  
   pivot (max(' + @pivotfield + ' ) FOR DotsNameDesc IN ('+ @cols + ')  
   ) AS P  
   ')  
    
 /*End: Pivot for Product with Status*/  
  
  /*Begin: Pivot for Product with Subassembly end value Modified on 09/08/2018*/  
   EXEC(';WITH PIVOT_DATA AS  
    (  
    select distinct  
      FeatureNameDesc,  
      SubAssemblyBaseDesc,  
      category as category ,  
      p.Dotsname as DotsNameDesc,  
      case when isnumeric(subassemblySpin)=1 then format(convert(numeric,isnull(nullif(subassemblySpin,''''),0)),''000'') else subassemblySpin end as subspin  
      ,r.DeliverableName  
    from #Result r  
    left join #ProductInfo p on p.productid = r.productversionid and p.releaseid=r.releaseid  
    where deliverableversionid is not null and  
     category is not null  
    group by   
      category,  
      SubAssemblyBaseDesc,  
      FeatureNameDesc,  
      p.Dotsname,  
      subassemblySpin  
      ,r.DeliverableName  
    ) SELECT 2 as GroupHeader , *  
    INTO  ' + @tmpHardwareMatrixSubAssemblyPivot + '  
    FROM PIVOT_DATA  
    pivot (max(subspin) FOR DotsNameDesc IN ('+ @cols + ')  
    ) AS P')  
 /*end: Pivot for Product with Subassembly end value 09/08/2018*/  
   end  
  
  --select 'Pivot Data is below'  
  --EXEC('SELECT * FROM ' + @tmpHardwareMatrixPivot );  
  --EXEC('SELECT * FROM ' + @tmpHardwareMatrixSubAssemblyPivot );  
  declare @eolDateTitle VARCHAR(50) = CASE WHEN @ReportFormat=5 THEN '[Service EOA]' ELSE '[Factory EOA]' END  
  Declare @ReporGroup3Columns varchar(MAX)  
  Declare @ReporGroup2Columns varchar(MAX)  
  /*Begin: Modified on 09/08/2018*/  
    set @ReporGroup3Columns ='select distinct  
          r.DeliverableName, r.Vendor, r.DeliverableVersionID,r.RootID,  
          r.Subassemblybase DelRootBase ,  
                                  GroupHeader ,  
                                  case when GroupHeader=3 then ''<a target=_blank style=text-decoration:underline href=/Pulsar/Component/EditVersionProperties?ComponentVersionId='' + cONVERT(VARCHAR(MAX),R.deliverableversionid) +''>''+ cONVERT(VARCHAR(MAX
),R.deliverableversionid) + ''</a>'' else R.FeatureNameDescDisplay end as FeatureNameDescDisplay,  
                                  FeatureNameDesc as FeatureNameDesc  
                                  '  
  
        set @ReporGroup2Columns ='select  
          DeliverableName, null as  Vendor, null as  DeliverableVersionID  
          ,null as RootID  
          ,null as DelRootBase,   
                                  GroupHeader,  
                                  null as FeatureNameDescDisplay,  
                                  FeatureNameDesc  
                                  '  
 IF @ReportFormat=2 OR  @ReportFormat=5  
 BEGIN  
  SET @ReporGroup3Columns = @ReporGroup3Columns + ',Bridged,null as QualStatus'  
  SET @ReporGroup2Columns = @ReporGroup2Columns + ',null as Bridged,null as QualStatus'  
 END  
 SET @ReporGroup3Columns = @ReporGroup3Columns + ' ,VendorWithSupplier as Supplier'  
 SET @ReporGroup2Columns = @ReporGroup2Columns + ',null as Supplier'  
  
 If @ReportFormat=6 and  @cntProduct = 1    
 begin  
  set @ReporGroup3Columns = @ReporGroup3Columns + ',SI1Date as [SI1 Available],SI2Date as [SI1 Available],SampleDateDesc'  
  set @ReporGroup2Columns = @ReporGroup2Columns + ',null as [SI1 Available],null as [SI2 Available],null as SampleDateDesc'  
 end  
 If @ReportFormat=1 or @ReportFormat=3 or @ReportFormat=6 OR  @ReportFormat=0  
    begin  
              set @ReporGroup3Columns = @ReporGroup3Columns + ',ComponentPM,''<a style=''''color:#337ab7;text-decoration:underline'''' href=''''javascript:ShowChanges(''+ convert(varchar(max),isnull(R.deliverableversionid,'''')) + '')''''>Notes</a>'' as [
Release Notes]'  
              set @ReporGroup2Columns = @ReporGroup2Columns + ',null as ComponentPM,null as [Release Notes]'  
    end  
  
 If @ReportFormat=3  
 begin  
      IF @cntproduct=1  
   BEGIN  
   set @ReporGroup3Columns = @ReporGroup3Columns + ',TestStatusDesc as QualStatus,PilotStatusDesc as PilotStatus'  
   set @ReporGroup2Columns = @ReporGroup2Columns + ',null as QualStatus,null as PilotStatus'  
   END  
   ELSE   
   BEGIN  
      set @ReporGroup3Columns = @ReporGroup3Columns + ',PilotStatusDesc as PilotStatus'  
      set @ReporGroup2Columns = @ReporGroup2Columns + ',null as PilotStatus'  
   END  
 end  
  
 If @ReportFormat=4  
 begin  
   IF @cntproduct=1  
   BEGIN  
   set @ReporGroup3Columns = @ReporGroup3Columns + ',TestStatusDesc as QualStatus,AccessoryStatusDesc as AccessoryStatus'  
   set @ReporGroup2Columns = @ReporGroup2Columns + ',null as QualStatus,null as AccessoryStatus'  
   END  
   ELSE   
   BEGIN  
   set @ReporGroup3Columns = @ReporGroup3Columns + ',AccessoryStatusDesc as AccessoryStatus'  
   set @ReporGroup2Columns = @ReporGroup2Columns + ',null as AccessoryStatus'  
   END  
 end  
  
 SET  @ReporGroup3Columns = @ReporGroup3Columns + ',  
                                  ModelNumber AS  ModelVendorPartNo,  
                                  version as HW ,  
          revision as FW,  
                                  pass as Rev,  
                                  RohsGreenSpec,  
                                  case when sampledate is not null then convert(varchar(10),sampledate,101) else '''' end as Samples ,  
                                  EOLDateDesc As ' + @eolDateTitle   
                                    
  
    SET  @ReporGroup2Columns = @ReporGroup2Columns + ',  
                                  null AS  ModelVendorPartNo,  
                                  null HW,  
          null FW,  
                                  null Rev,  
                                  null as RohsGreenSpec,  
                                  null as Samples ,  
                                  null As ' + @eolDateTitle   
  
  
 If NOT(@ReportFormat=6 and @cntProduct=1)  
 BEGIN  
   IF @cntProduct = 1  
   BEGIN  
    set @ReporGroup3Columns = @ReporGroup3Columns + ',DCRDesc as DCRHFCN,AssemblyCode as ACode'  
    set @ReporGroup2Columns = @ReporGroup2Columns + ',null as DCRHFCN,null as ACode'  
   END  
   ELSE   
   BEGIN  
    set @ReporGroup3Columns = @ReporGroup3Columns + ',AssemblyCode as ACode'  
    set @ReporGroup2Columns = @ReporGroup2Columns + ',null as ACode'  
   END  
 END  
 SET @ReporGroup3Columns = @ReporGroup3Columns +',R.category,R.Partnumber as HPPartNo'  
    SET @ReporGroup2Columns = @ReporGroup2Columns +',category,SubAssemblyBaseDesc as HPPartNo'  
  
 if @cols is not null  
  begin  
   IF @cntProduct = 1  
   BEGIN  
    EXEC(@ReporGroup3Columns +  
       ',' + @cols + ' ,TargetNotes as Comments  
       into '+ @tmpHardwareMatrixReport +'  
     from #Result R  
     left join '+ @tmpHardwareMatrixPivot + ' P on R.deliverableversionid = P.deliverableversionid and R.category = P.category  
     WHERE GroupHeader  <> 2 and R.subassemblybase = P.subassemblybase  
     union ' + @ReporGroup2Columns + ',' +  
     
      @cols + ' ,null as Comments  
     from  
    ' + @tmpHardwareMatrixSubAssemblyPivot   
    )  
    IF @ReportFormat=2 or  @ReportFormat=5  
    BEGIN  
     exec('UPDATE ' + @tmpHardwareMatrixReport + ' SET '+@cols+' ='''',HPPartNo = Replace(HPPartNo,''xxx'','+@cols+' ) WHERE GroupHeader = 2')   
    END  
   END  
   ELSE  
   BEGIN  
   EXEC(@ReporGroup3Columns +  
       ',' + @cols +  
      ' into '+ @tmpHardwareMatrixReport +'  
     from #Result R  
     left join '+ @tmpHardwareMatrixPivot + ' P on R.deliverableversionid = P.deliverableversionid and R.category = P.category  
     WHERE GroupHeader  <> 2 and R.subassemblybase = P.subassemblybase  
     union ' + @ReporGroup2Columns + ',' +  
     
      @cols +  
     'from  
    ' + @tmpHardwareMatrixSubAssemblyPivot   
    )  
   END  
      
  end  
  else  
  begin  
   EXEC (@ReporGroup3Columns + '  
     INTO  ' + @tmpHardwareMatrixReport + '  
     FROM #Result R')  
  end  
  
  /*Include Group Header1*/  
  Exec('INSERT INTO ' + @tmpHardwareMatrixReport + '(GroupHeader,category)   
  SELECT DISTINCT 1 as GroupHeader,category   
  from  #Result')  
  
    
  exec ('update ' + @tmpHardwareMatrixReport + ' set FeatureNameDescDisplay=''<div id=GroupHeader1 style=background-color:SeaGreen;font-weight:bolder;>''+ ISNULL(category,'''')+''</div>'' where GroupHeader=1')  
  exec ('update ' + @tmpHardwareMatrixReport + ' set FeatureNameDescDisplay=''<div id=GroupHeader2 style=background-color:BurlyWood>''+ ISNULL(FeatureNameDesc,'''')+''</div>'' where GroupHeader=2')  
  
  /* Modified on 09/08/2018*/  
  /* Modified on 27/07/2018*/  
  exec(   
  'update A   
  set A.DelRootBase = B.DelRootBase, A.RootID = B.RootID  
  from ' + @tmpHardwareMatrixReport + ' A   
  inner join ' + @tmpHardwareMatrixReport + ' B on A.FeatureNameDesc = B.FeatureNameDesc and A.Category = B.Category  
  where A.GroupHeader = 2 and B.GroupHeader = 3'  
  )  
  
  exec('update A   
  set A.Delrootbase = (select Max(B.Delrootbase) from ' + @tmpHardwareMatrixReport + ' B  
       where A.FeatureNameDesc = B.FeatureNameDesc and A.Category = B.Category   
      group by B.category,B.FeatureNameDesc)  
  from ' + @tmpHardwareMatrixReport + ' A   
  where  A.Delrootbase is null')  
  
  exec('update A   
  set A.Vendor = (select Min(B.Vendor) from ' + @tmpHardwareMatrixReport + '  B  
       where A.FeatureNameDesc = B.FeatureNameDesc and A.Category = B.Category   
      group by B.category,B.FeatureNameDesc)  
  from ' + @tmpHardwareMatrixReport + '  A   
  where  A.GroupHeader = 2')  
  
  --exec('update A   
  --set A.Vendor = (select Min(B.Vendor) from ' + @tmpHardwareMatrixReport + '  B  
  --     where A.FeatureNameDesc = B.FeatureNameDesc and A.Category = B.Category   
  --    group by B.category,B.FeatureNameDesc)  
  --from ' + @tmpHardwareMatrixReport + '  A   
  --where  A.GroupHeader = 2')  
  
  /* Included on 21/08/2018 */  
  if @ReportFormat = 2   
  begin  
  
  EXEC('update A   
  set A.FeatureNameDesc = (select Max(B.FeatureNameDesc) from ' + @tmpHardwareMatrixReport + '  B  
       where A.Category = B.Category and A.RootID = B.RootID and A.DelRootBase = B.DelRootBase  
      group by Category,RootID,DelRootBase)  
  from ' + @tmpHardwareMatrixReport + '  A   
  ')  
  --where  A.GroupHeader = 2  
  
  EXEC(';With CTE_Duplicates1 as  
   (select Category,RootID,DelRootBase,row_number() over(partition by Category,RootID,DelRootBase order by Category,RootID,DelRootBase,FeatureNameDesc) rownumber   
   from ' + @tmpHardwareMatrixReport + ' Where GroupHeader = 2)  
   delete from CTE_Duplicates1 where rownumber!=1')  
  
  end  
  /* Included on 21/08/2018 */  
  
  exec('update A   
  set A.DeliverableVersionID = (select Min(B.DeliverableVersionID) from ' + @tmpHardwareMatrixReport + '  B  
       where A.FeatureNameDesc = B.FeatureNameDesc and A.Category = B.Category   
      group by B.category,B.FeatureNameDesc)  
  from ' + @tmpHardwareMatrixReport + '  A   
  where  A.GroupHeader = 2')  
  
  
  
  --if @ReportFormat = 2   
    
  --  SET @OrderByClause =  'category, isnull(DelRootBase,RootID), RootID, Vendor, isnull(cast(DeliverableVersionID as varchar(max)),FeatureNameDesc),FeatureNameDesc asc,GroupHeader asc'  
  --else if @ReportFormat =  5   
  --  SET @OrderByClause =  'category, isnull(DelRootBase,RootID), Vendor, isnull(cast(DeliverableVersionID as varchar(max)),FeatureNameDesc),FeatureNameDesc asc,GroupHeader asc'  
  --else  
  --  SET @OrderByClause =  'category, DeliverableName, Vendor, isnull(cast(DeliverableVersionID as varchar(max)),FeatureNameDesc),FeatureNameDesc asc,GroupHeader asc  
  
    if @ReportFormat = 2   
    SET @OrderByClause =  'category, DelRootBase, RootID, Vendor, DeliverableVersionID asc,FeatureNameDesc asc,GroupHeader asc'  
  else if @ReportFormat =  5   
    SET @OrderByClause =  'category, DelRootBase, Vendor, DeliverableVersionID asc,FeatureNameDesc asc,GroupHeader asc'  
  else  
    SET @OrderByClause =  'category, DeliverableName,  Vendor, DeliverableVersionID asc,FeatureNameDesc asc,GroupHeader asc'  
  
    Declare @ReportOrder varchar(100)  
    if @ReportFormat = 2   
    SET @ReportOrder =  'category, DelRootBase, RootID, Vendor, DeliverableVersionID,GroupHeader'  
  else if @ReportFormat =  5   
    SET @ReportOrder =  'category, DelRootBase, Vendor, DeliverableVersionID,GroupHeader'  
  else  
    SET @ReportOrder =  'category, DeliverableName,  Vendor, DeliverableVersionID,GroupHeader'  
        
   exec(';With CTE_Duplicates as  
    (select '+ @ReportOrder + ', row_number() over(partition by '+ @ReportOrder + ' order by '+ @ReportOrder +' ) rownumber   
    from ' + @tmpHardwareMatrixReport + ')  
    delete from CTE_Duplicates where rownumber!=1')  
  
  /*End: Modified on 09/08/2018*/  
  
  --/* Pagination  
  --select 'All Data with pagination'  
  DECLARE @sqlquery NVARCHAR(MAX)   
  IF ISNULL(@OrderByClause, '') = ''   
   BEGIN   
    SET @OrderByClause = 'category asc,FeatureNameDesc asc,GroupHeader asc'   
   END   
    
    
  declare @where varchar(max)  
  
              if @WhereClause <> ''  
              begin  
                     set @where = @WhereClause  
                     set @WhereClause = ' (' + @where + 'and Groupheader = 3)  
                     OR  (Groupheader = 2 and FeatureNameDesc in (select  distinct FeatureNameDesc from ' + @tmpHardwareMatrixReport + ' where ' + @where + '))  
                     OR  (Groupheader = 1 and Category in (select  distinct Category from ' + @tmpHardwareMatrixReport + ' where ' + @where + ' ))'  
              End  
  
  
  SET @sqlquery = dbo.GetPaginationQuery(@tmpHardwareMatrixReport,   
      @PageNo,   
      @PageSize,   
      @OrderByClause,   
      @WhereClause)   
  
  EXECUTE sp_executesql   
   @sqlquery  
  
  END  
  
  --COMMIT TRAN HWTrans  
 END TRY  
 BEGIN CATCH  
  IF ISNULL(@ErrorMessage,'')<>''  
   SELECT @ErrorMessage AS ErrorMessage  
  ELSE  
   SELECT Error_Message() AS ErrorMessage  
  --   IF(@@TRANCOUNT>0)   
  --BEGIN    
  -- ROLLBACK TRAN HWTrans    
  --END    
 END CATCH  
   
 -- Finally   
  if object_id(@tmpHardwareMatrixReport) is not null EXEC ('DROP TABLE ' + @tmpHardwareMatrixReport)   
  if object_id('tempdb..#Result') is not null DROP TABLE #Result  
  if object_id('tempdb..#tsb') is not null DROP TABLE #tsb  
  if object_id('tempdb..#TMP1') is not null DROP TABLE #TMP1  
  if object_id('tempdb..#TMP2') is not null DROP TABLE #TMP2   
  if object_id('tempdb..#ListSubassembliesForBase') is not null DROP TABLE #ListSubassembliesForBase  
  if object_id('tempdb..#ListSubassembliesForRoot') is not null DROP TABLE #ListSubassembliesForRoot  
  if object_id('tempdb..#NativeSubAssemblyBase') is not null DROP TABLE #NativeSubAssemblyBase  
  if object_id('tempdb..#ProductInfo') is not null DROP TABLE #ProductInfo  
  if object_id(@tmpHardwareMatrixSubAssemblyPivot) is not null EXEC ('DROP TABLE ' + @tmpHardwareMatrixSubAssemblyPivot)  
        if object_id(@tmpHardwareMatrixPivot) is not null EXEC ('DROP TABLE ' + @tmpHardwareMatrixPivot)  
 -- Finally  
END