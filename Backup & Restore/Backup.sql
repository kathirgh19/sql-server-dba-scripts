
--Backup from MI001EQAISQL01-AO1 Server

BACKUP DATABASE [PLT_AI] 
TO DISK = N'K:\BACKUP\PLT_AI_04132023.bak' 
WITH  COPY_ONLY,
NOFORMAT, NOINIT,  
NAME = N'PLT_AI-Full Database Backup', 
SKIP, NOREWIND, NOUNLOAD,  STATS = 10


BACKUP DATABASE [ECOL_D365Integration] 
TO DISK = N'K:\BACKUP\ECOL_D365Integration_04132023.bak' 
WITH  COPY_ONLY, 
NOFORMAT, NOINIT,  
NAME = N'ECOL_D365Integration-Full Database Backup', 
SKIP, NOREWIND, NOUNLOAD,  STATS = 10




--Backup dbs with Time stampings

DECLARE @name VARCHAR(50) = 'PLT_AI' -- database name 
DECLARE @path VARCHAR(256) -- path for backup files 
DECLARE @fileName VARCHAR(256) = 'PLT_AI' -- filename for backup 
DECLARE @fileDate VARCHAR(20) -- used for file name
 
-- specify database backup directory e.g. 'D:\backup\'
SET @path = '\\10.2.76.101\MI001SQL01\MI001EQAISQLC01$PRDEQAISQLAG\PLT_AI\FULL\'
 
-- specify filename format
SELECT @fileDate = CONVERT(VARCHAR(20),GETDATE(),112) + '_' + REPLACE(CONVERT(VARCHAR(20),GETDATE(),108),':','')

SET @fileName = @path + @name + '_' + @fileDate + '.BAK'
BACKUP DATABASE @name TO DISK = @fileName;

------------------------------------------------------------------------------
SET @name = 'Plt_Image'
SET @path = '\\10.2.76.101\MI001SQL01\MI001EQAISQLC01$PRDEQAISQLAG\Plt_Image\FULL\'
SET @fileName = @path + @name + '_' + @fileDate + '.BAK'
BACKUP DATABASE @name TO DISK = @fileName;

-- specify database backup directory e.g. 'D:\backup\'
SET @path = '\\10.2.76.101\MI001SQL01\MI001EQAISQLC01$PRDEQAISQLAG\COR_DB\FULL\'
 
-- specify filename format
SELECT @fileDate = CONVERT(VARCHAR(20),GETDATE(),112) + '_' + REPLACE(CONVERT(VARCHAR(20),GETDATE(),108),':','')

SET @fileName = @path + @name + '_' + @fileDate + '.BAK'
BACKUP DATABASE @name TO DISK = @fileName;

------------------------------------------------------------------------------
SET @name = 'Plt_Image_0136'
SET @path = '\\10.2.76.101\MI001SQL01\MI001EQAISQLC01$PRDEQAISQLAG\Plt_Image_0136\FULL\'
SET @fileName = @path + @name + '_' + @fileDate + '.BAK'
BACKUP DATABASE @name TO DISK = @fileName;

------------------------------------------------------------------------------
SET @name = 'Plt_Image_0137'
SET @path = '\\10.2.76.101\MI001SQL01\MI001EQAISQLC01$PRDEQAISQLAG\Plt_Image_0137\FULL\'
SET @fileName = @path + @name + '_' + @fileDate + '.BAK'
BACKUP DATABASE @name TO DISK = @fileName;

------------------------------------------------------------------------------
SET @name = 'Plt_Image_0138'
SET @path = '\\10.2.76.101\MI001SQL01\MI001EQAISQLC01$PRDEQAISQLAG\Plt_Image_0138\FULL\'
SET @fileName = @path + @name + '_' + @fileDate + '.BAK'
BACKUP DATABASE @name TO DISK = @fileName;

------------------------------------------------------------------------------
SET @name = 'COR_DB'
SET @path = '\\10.2.76.101\MI001SQL01\MI001EQAISQLC01$PRDEQAISQLAG\COR_DB\FULL\'
SET @fileName = @path + @name + '_' + @fileDate + '.BAK'
BACKUP DATABASE @name TO DISK = @fileName;