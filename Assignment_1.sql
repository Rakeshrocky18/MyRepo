-- Creating table account 

create table account(accountNumber int primary key auto_increment, customerName varchar(30) not null, balance numeric(10,2));
drop table account_update;
drop table account;

-- Inserting values into account

insert into account(customerName,balance) values("Rakesh",30000);
insert into account(customerName,balance) values("Naruto",50000);
insert into account(customerName,balance) values("Naruto",50000);



 -- creating account_update table
 
create table account_update(accountNumber int,
customerName varchar(30) not null,
changed_id timestamp,
old_balance numeric(10,2) not null,
transaction_amount numeric(10,2) not null,
transactionType varchar(30) not null,
new_balance numeric(10,2) not null);

--  drop trigger account_update_ddebit
 


-- creating trigger for debit type of transaction

delimiter $$
 create trigger account_update_debit  before update on account for each row
 begin
 if(old.balance>new.balance) then
    insert into account_update(accountNumber,customerName,changed_id,transactionType, old_balance ,new_balance,transaction_amount)
    values(old.accountNumber,old.customerName, now(),'debit', old.balance, new.balance, old.balance-new.balance);
    END IF;
end$$


-- creating trigger for credit type of transaction
delimiter ||
 create trigger account_update_credit  before update on account for each row
 begin
 if(old.balance<new.balance) then
    insert into account_update(accountNumber,customerName,changed_id,transactionType, old_balance ,new_balance, transaction_amount)
    values(old.accountNumber,old.customerName, now(),'credit', old.balance, new.balance, new.balance-old.balance);
    END IF;
end||


drop trigger account_update_credit
 


-- Updating the account table with new balance 
 
update account set balance=balance-6000 where accountNumber=1;
update account set balance=balance+15000 where accountNumber=1;

-- creating procedure to get the sum of withdrawal and deposit

delimiter %%
create procedure sumWithdrawal(in acc_No int, out totalDebit numeric(10,2), out totalCredit numeric(10,2))
begin
select sum(old_balance-new_balance) into totalDebit from account_update where  transactionType='debit' and accountNumber=acc_No;
select sum(new_balance-old_balance) into totalCredit from account_update where  transactionType='credit' and accountNumber=acc_No;
end %%

-- for dropping the procedure

drop procedure sumWithdrawal;

-- calling the procedure

call sumWithdrawal(1, @totalDebit,@totalCredit); 

-- printing the called procedure

select @totalDebit,@totalCredit 