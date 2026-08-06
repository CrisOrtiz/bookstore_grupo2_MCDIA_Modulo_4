CREATE PROCEDURE [dbo].[LoadDimBook]
AS
BEGIN
    SET NOCOUNT ON;

    MERGE [dbo].[DimBook] AS target
    USING (
        SELECT
            [book_id],
            [title],
            [isbn13],
            [language_code],
            [language_name],
            [num_pages],
            [publication_date],
            [publisher_name],
            [author_name]
        FROM [staging].[book]
    ) AS source
    ON  target.[BookID] = source.[book_id]
    WHEN MATCHED THEN
        UPDATE SET
            [Title]           = source.[title],
            [ISBN13]          = source.[isbn13],
            [LanguageCode]    = source.[language_code],
            [LanguageName]    = source.[language_name],
            [NumPages]        = source.[num_pages],
            [PublicationDate] = source.[publication_date],
            [PublisherName]   = source.[publisher_name],
            [AuthorName]      = source.[author_name]
    WHEN NOT MATCHED BY TARGET THEN
        INSERT ([BookID], [Title], [ISBN13], [LanguageCode], [LanguageName],
                [NumPages], [PublicationDate], [PublisherName], [AuthorName])
        VALUES (source.[book_id], source.[title], source.[isbn13], source.[language_code], source.[language_name],
                source.[num_pages], source.[publication_date], source.[publisher_name], source.[author_name]);
END
