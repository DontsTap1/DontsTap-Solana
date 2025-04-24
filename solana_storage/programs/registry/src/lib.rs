use std::str::FromStr;

use anchor_lang::{prelude::*, solana_program::system_program, Discriminator};

declare_id!("D9nau9c2BjDnkSwJQblorlQfDRt9LygatVuQhsVnspJ");

const SERVICE: &str = "AcwHS8HMAvporcSBXJhajoDM2DDeQNygkq2YgaZFq1pq";

fn is_authorized(signer: Pubkey) -> Result<()> {
    let service: Pubkey = Pubkey::from_str(SERVICE).expect("Invalid service public key");
    require_keys_eq!(signer, service, UsersError::Unauthorized);
    Ok(())
}

fn is_initialized(actual_discriminator: &[u8]) -> Result<()> {
    require!(
        Users::discriminator() == actual_discriminator,
        UsersError::Uninitialized
    );
    Ok(())
}

#[program]
pub mod registry {

    use super::*;

    // Register new user
    pub fn register_user(
        ctx: Context<RegisterUser>,
        user_id: String,
        auth_id: String,
    ) -> Result<()> {
        is_authorized(ctx.accounts.signer.key())?;
        let user = &mut ctx.accounts.user;
        user.user_id = user_id;
        user.auth_id = auth_id;
        Ok(())
    }

    // Transfer coins of users to new user
    pub fn transfer_user(ctx: Context<TransferCoin>, user_id: String) -> Result<()> {
        is_authorized(ctx.accounts.signer.key())?;
        is_initialized(&ctx.accounts.users.to_account_info().data.borrow()[..8])?;
        let users = &mut ctx.accounts.users;
        require!(users.auth_id != user_id, UsersError::NotFound);
        users.auth_id = auth_id;
        Ok(())
    }
}

// Users data structure, storing essential information about each user.

#[account]
#[derive(InitSpace)]
pub struct User {
    #[max_len(20)]
    pub user_id: String,
    #[max_len(20)]
    pub auth_id: String,
}

// Context structs for each instruction, defining the accounts required for each operation.

#[derive(Accounts)]
#[instruction(user_id:String)]
pub struct RegisterUser<'info> {
    #[account(mut)]
    pub signer: Signer<'info>,
    #[account(
        init,
        payer = signer,
        space = 8 + Users::INIT_SPACE,
        seeds = [b"mapping-", user_id.as_bytes()],
        bump
    )]
    pub users: Account<'info, Users>,
    #[account(address = system_program::ID)]
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct TransferCoins<'info> {
    #[account(signer)]
    pub signer: Signer<'info>,
    #[account(mut)]
    pub users: Account<'info, Users>,
}

// Error codes to handle various user-related errors.

#[error_code]
pub enum UsersError {
    #[msg("Unauthorized access")]
    Unauthorized,
    #[msg("Uninitialized user account")]
    Uninitialized,
    #[msg("Invalid auth of user account")]
    InvalidOwner,
    #[msg("Not found")]
    NotFound,
}
