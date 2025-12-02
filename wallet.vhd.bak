library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

entity wallet is
    generic (
        WALLET_ID_WIDTH  : integer := 16;
        BALANCE_WIDTH    : integer := 32
    );
    port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        wallet_id_in    : in  std_logic_vector(WALLET_ID_WIDTH-1 downto 0);
        wallet_load     : in  std_logic;
        deposit_req     : in  std_logic;
        withdraw_req    : in  std_logic;
        amount_in       : in  std_logic_vector(BALANCE_WIDTH-1 downto 0);
        wallet_id_out   : out std_logic_vector(WALLET_ID_WIDTH-1 downto 0);
        balance_out     : out std_logic_vector(BALANCE_WIDTH-1 downto 0);
        valid_op_out    : out std_logic
    );
end entity;

architecture Behavioral of wallet is

    signal wallet_id_reg : std_logic_vector(WALLET_ID_WIDTH-1 downto 0) := (others => '0');
    signal balance_reg   : unsigned(BALANCE_WIDTH-1 downto 0) := (others => '0');
    signal valid_op_reg  : std_logic := '0';

begin

    process(clk, reset)
    begin
        if reset = '1' then
            wallet_id_reg <= (others => '0');
            balance_reg   <= (others => '0');
            valid_op_reg  <= '0';

        elsif rising_edge(clk) then
            
            valid_op_reg <= '0';
            if wallet_load = '1' then
                wallet_id_reg <= wallet_id_in;
                valid_op_reg <= '1';
            end if;
            if deposit_req = '1' then
                balance_reg <= balance_reg + unsigned(amount_in);
                valid_op_reg <= '1';
            end if;
            if withdraw_req = '1' then
                if balance_reg >= unsigned(amount_in) then
                    balance_reg <= balance_reg - unsigned(amount_in);
                    valid_op_reg <= '1';
                else
                    valid_op_reg <= '0';
                end if;
            end if;

        end if;
    end process;

    wallet_id_out <= wallet_id_reg;
    balance_out   <= std_logic_vector(balance_reg);
    valid_op_out  <= valid_op_reg;

end architecture;

