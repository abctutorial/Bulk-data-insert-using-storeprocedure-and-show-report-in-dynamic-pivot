USE [master]
GO
/****** Object:  Database [TechnicalTest]    Script Date: 2/14/2022 12:11:33 AM ******/
CREATE DATABASE [TechnicalTest]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'TechnicalTest', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\TechnicalTest.mdf' , SIZE = 3136KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'TechnicalTest_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\TechnicalTest_log.ldf' , SIZE = 784KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [TechnicalTest] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [TechnicalTest].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [TechnicalTest] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [TechnicalTest] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [TechnicalTest] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [TechnicalTest] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [TechnicalTest] SET ARITHABORT OFF 
GO
ALTER DATABASE [TechnicalTest] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [TechnicalTest] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [TechnicalTest] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [TechnicalTest] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [TechnicalTest] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [TechnicalTest] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [TechnicalTest] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [TechnicalTest] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [TechnicalTest] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [TechnicalTest] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [TechnicalTest] SET  DISABLE_BROKER 
GO
ALTER DATABASE [TechnicalTest] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [TechnicalTest] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [TechnicalTest] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [TechnicalTest] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [TechnicalTest] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [TechnicalTest] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [TechnicalTest] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [TechnicalTest] SET RECOVERY FULL 
GO
ALTER DATABASE [TechnicalTest] SET  MULTI_USER 
GO
ALTER DATABASE [TechnicalTest] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [TechnicalTest] SET DB_CHAINING OFF 
GO
ALTER DATABASE [TechnicalTest] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [TechnicalTest] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
USE [TechnicalTest]
GO
/****** Object:  Schema [Employee]    Script Date: 2/14/2022 12:11:33 AM ******/
CREATE SCHEMA [Employee]
GO
/****** Object:  Schema [Pay]    Script Date: 2/14/2022 12:11:33 AM ******/
CREATE SCHEMA [Pay]
GO
/****** Object:  UserDefinedTableType [dbo].[tpEmpBonus_List]    Script Date: 2/14/2022 12:11:33 AM ******/
CREATE TYPE [dbo].[tpEmpBonus_List] AS TABLE(
	[Emp_Id] [varchar](200) NULL,
	[Emp_Name] [varchar](200) NULL,
	[Emp_Bonus] [decimal](20, 2) NULL
)
GO
/****** Object:  StoredProcedure [dbo].[Report_Dynamic_Salary_Head_Wise_Sheet]    Script Date: 2/14/2022 12:11:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Report_Dynamic_Salary_Head_Wise_Sheet]
AS
BEGIN
			--Declare Variable  
			DECLARE @Pivot_Column [nvarchar](max);  
			DECLARE @Query [nvarchar](max);  
  
			--Select Pivot Column 
			SELECT @Pivot_Column= COALESCE(@Pivot_Column+',','')+ QUOTENAME(BreakupName) FROM  
			(SELECT DISTINCT SB.BreakupName FROM [Pay].[SalaryDetails] SD
			JOIN [Pay].[SalaryBreakUp] SB ON SD.BreakupID=SB.BreakupID)Tab  

			--Create Dynamic Query
			SELECT @Query='SELECT EmployeeID, '+@Pivot_Column+' FROM   
			(SELECT SD.EmployeeID, SB.BreakupName , SD.BreakupAmount FROM [Pay].[SalaryDetails] SD
			JOIN [Pay].[SalaryBreakUp] SB ON SD.BreakupID=SB.BreakupID )Tab1  
			PIVOT  
			(  
			SUM(BreakupAmount) FOR [BreakupName] IN ('+@Pivot_Column+')) AS Tab2  
			ORDER BY Tab2.EmployeeID'  
  
			--Execute Query 
			EXEC  sp_executesql  @Query 
END

GO
/****** Object:  StoredProcedure [dbo].[SaveEmpBonusRecord]    Script Date: 2/14/2022 12:11:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SaveEmpBonusRecord]
  @arrayList AS dbo.tpEmpBonus_List READONLY
AS
BEGIN

--This is for inserting bulk records
INSERT INTO [Employee].[EmployeeBonusDetail]
           ([EmployeeId]
           ,[EmployeeName]
           ,[EmployeeBonusAmount])
SELECT 
    Emp_Id as EmployeeId, Emp_Name as EmployeeName, Emp_Bonus as EmployeeBonusAmount
FROM 
    @arrayList



--This is for return saved records 
	SELECT 
    Emp_Name
FROM 
    @arrayList

END


GO
/****** Object:  Table [Employee].[Area]    Script Date: 2/14/2022 12:11:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [Employee].[Area](
	[AreaID] [nchar](4) NOT NULL,
	[AreaName] [varchar](50) NULL,
	[Setdate] [datetime] NULL,
	[Username] [varchar](50) NULL,
 CONSTRAINT [PK_Area] PRIMARY KEY CLUSTERED 
(
	[AreaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [Employee].[EmployeeBonusDetail]    Script Date: 2/14/2022 12:11:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Employee].[EmployeeBonusDetail](
	[EmployeeId] [nvarchar](250) NOT NULL,
	[EmployeeName] [nvarchar](max) NULL,
	[EmployeeBonusAmount] [decimal](20, 2) NULL,
 CONSTRAINT [PK_EmployeeBonusDetail] PRIMARY KEY CLUSTERED 
(
	[EmployeeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [Employee].[EmployeeTransfer]    Script Date: 2/14/2022 12:11:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [Employee].[EmployeeTransfer](
	[EmployeeID] [varchar](3) NOT NULL,
	[AreaID] [nchar](4) NOT NULL,
	[ProjectID] [nchar](3) NOT NULL,
	[EffectiveDate] [date] NOT NULL,
	[Setdate] [datetime] NULL,
	[UserName] [varchar](50) NULL,
 CONSTRAINT [PK_Employee.EmployeeTransfer] PRIMARY KEY CLUSTERED 
(
	[EmployeeID] ASC,
	[AreaID] ASC,
	[ProjectID] ASC,
	[EffectiveDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [Pay].[SalaryBreakUp]    Script Date: 2/14/2022 12:11:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [Pay].[SalaryBreakUp](
	[BreakupID] [nchar](2) NOT NULL,
	[BreakupName] [varchar](50) NOT NULL,
	[Setdate] [datetime] NULL,
	[UserName] [varchar](50) NULL,
 CONSTRAINT [PK_SalaryBreakUp] PRIMARY KEY CLUSTERED 
(
	[BreakupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [Pay].[SalaryDetails]    Script Date: 2/14/2022 12:11:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [Pay].[SalaryDetails](
	[EmployeeID] [nchar](3) NOT NULL,
	[BreakupID] [nchar](2) NOT NULL,
	[BreakupAmount] [money] NOT NULL,
	[Setdate] [datetime] NOT NULL,
	[UserName] [varchar](50) NOT NULL,
 CONSTRAINT [PK_SalaryDetails] PRIMARY KEY CLUSTERED 
(
	[EmployeeID] ASC,
	[BreakupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  UserDefinedFunction [dbo].[Func_Get_Area_By_EmployeeId_EffectiveDate]    Script Date: 2/14/2022 12:11:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[Func_Get_Area_By_EmployeeId_EffectiveDate] (
	@EmployeeID varchar(3),
	@EffectiveDate datetime
)
RETURNS TABLE AS
    RETURN (select AreaName From Employee.EmployeeTransfer ET
JOIN Employee.Area A ON ET.AreaID=A.AreaID
WHERE ET.EmployeeID=@EmployeeID AND ET.EffectiveDate=convert(varchar, @EffectiveDate, 23))




GO
USE [master]
GO
ALTER DATABASE [TechnicalTest] SET  READ_WRITE 
GO
