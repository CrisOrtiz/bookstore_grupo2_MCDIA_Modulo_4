CREATE TABLE [dbo].[customer_address] (
    [customer_id] INT        NOT NULL,
    [address_id]  INT        NOT NULL,
    [status_id]   INT        NULL,
    [rowversion]  ROWVERSION NOT NULL,
    CONSTRAINT [pk_custaddr] PRIMARY KEY CLUSTERED ([customer_id] ASC, [address_id] ASC),
    CONSTRAINT [fk_ca_addr] FOREIGN KEY ([address_id]) REFERENCES [dbo].[address] ([address_id]),
    CONSTRAINT [fk_ca_cust] FOREIGN KEY ([customer_id]) REFERENCES [dbo].[customer] ([customer_id]),
    CONSTRAINT [fk_customer_address_addres_status_id] FOREIGN KEY ([status_id]) REFERENCES [dbo].[address_status] ([status_id]) ON DELETE CASCADE ON UPDATE CASCADE
);

