CREATE TABLE [Uncompressed_Table](
   [ID] [int] IDENTITY(1,1) NOT NULL,
   [Text_stored] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_Uncompressed_Table] PRIMARY KEY CLUSTERED 
(
   [ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

-----------

CREATE TABLE [Compressed_Table](
   [ID] [int] NOT NULL,
   [Text_stored] [varbinary](max) NOT NULL,
 CONSTRAINT [PK_Compressed_Table] PRIMARY KEY CLUSTERED 
(
   [ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

DECLARE @i int
SET @i =RAND()*500
INSERT INTO [Uncompressed_Table] VALUES(REPLICATE ('ABC' ,@i ))
INSERT INTO [Uncompressed_Table] VALUES(REPLICATE ('X' ,@i ))
INSERT INTO [Uncompressed_Table] VALUES(REPLICATE ('Y' ,@i ))
INSERT INTO [Uncompressed_Table] VALUES(REPLICATE ('Z' ,@i ))
INSERT INTO [Uncompressed_Table] VALUES(REPLICATE ('$' ,@i ))
INSERT INTO [Uncompressed_Table] VALUES(REPLICATE ('--' ,@i ))
GO 10000

EXEC sp_spaceused N'Uncompressed_Table'; 
EXEC sp_spaceused N'Compressed_Table'; 
GO

SELECT * FROM Uncompressed_Table;
GO

INSERT INTO [Compressed_Table]
SELECT 
   ID,
   COMPRESS([Text_stored])
FROM [Uncompressed_Table];
GO

EXEC sp_spaceused N'Uncompressed_Table'; 
EXEC sp_spaceused N'Compressed_Table'; 
GO

SELECT * FROM Compressed_Table;
GO

SELECT 
   ID,
   CAST(DECOMPRESS(Text_stored) AS NVARCHAR(max)) AS Readable_text
FROM [Compressed_Table];
GO