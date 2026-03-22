-- Gộp về một cột ảnh đại diện: profile_picture_url (bảng Users).
-- KHÔNG xóa Pets.photoUrl — đó là ảnh thú cưng, khác bảng.
IF COL_LENGTH(N'dbo.Users', N'photoUrl') IS NOT NULL
BEGIN
    UPDATE dbo.Users
    SET profile_picture_url = photoUrl
    WHERE (profile_picture_url IS NULL OR LTRIM(RTRIM(profile_picture_url)) = N'')
      AND photoUrl IS NOT NULL AND LTRIM(RTRIM(photoUrl)) <> N'';

    ALTER TABLE dbo.Users DROP COLUMN photoUrl;
END
GO
