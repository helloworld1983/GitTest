-------------------------------------------------------------------------------
-- Title      : Fixed sin-cos DDS
-- Project    : 
-------------------------------------------------------------------------------
-- File       : fixed_dds.vhd
-- Author     : aylons  <aylons@LNLS190>
-- Company    : 
-- Created    : 2014-03-07
-- Last update: 2014-03-07
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Fixed frequency phase and quadrature DDS for use in tuned DDCs.
-------------------------------------------------------------------------------
-- Copyright (c) 2014 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2014-03-07  1.0      aylons  Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.vcomponents.all;

library work;
use work.genram_pkg.all;
-------------------------------------------------------------------------------

entity fixed_dds is

  generic (
    g_number_of_points : natural := 148;
    g_output_width     : natural := 24;
    g_dither           : boolean := false;
    g_sin_file         : string  := "./dds_sin.ram";
    g_cos_file         : string  := "./dds_cos.ram"
    );
  port (
    clk_i     : in  std_logic;
    ce_i      : in  std_logic;
    rst_n_i   : in  std_logic;
    sin_o     : out std_logic_vector(g_output_width-1 downto 0);
    cos_o     : out std_logic_vector(g_output_width-1 downto 0)
    );

end entity fixed_dds;

-------------------------------------------------------------------------------

architecture str of fixed_dds is

  constant c_bus_size : natural := f_log2_size(g_number_of_points);
  signal cur_address  : std_logic_vector(c_bus_size-1 downto 0);

  component generic_simple_dpram is
    generic (
      g_data_width               : natural;
      g_size                     : natural;
      g_with_byte_enable         : boolean;
      g_addr_conflict_resolution : string;
      g_init_file                : string;
      g_dual_clock               : boolean);
    port (
      rst_n_i : in  std_logic                                        := '1';
      clka_i  : in  std_logic;
      bwea_i  : in  std_logic_vector((g_data_width+7)/8 -1 downto 0) := f_gen_dummy_vec('1', (g_data_width+7)/8);
      wea_i   : in  std_logic;
      aa_i    : in  std_logic_vector(c_bus_size-1 downto 0);
      da_i    : in  std_logic_vector(g_data_width-1 downto 0);
      clkb_i  : in  std_logic;
      ab_i    : in  std_logic_vector(c_bus_size-1 downto 0);
      qb_o    : out std_logic_vector(g_data_width-1 downto 0));
  end component generic_simple_dpram;
  
  component lut_sweep is
    generic (
      g_bus_size      : natural;
      g_first_address : natural;
      g_last_address  : natural;
      g_sweep_mode    : string);
    port (
      rst_n_i : in  std_logic;
      clk_i   : in  std_logic;
      ce_i      : in  std_logic;
      address_o : out std_logic_vector(c_bus_size-1 downto 0));
  end component lut_sweep;

begin  -- architecture str

  cmp_sin_lut : generic_simple_dpram
    generic map (
      g_data_width               => g_output_width,
      g_size                     => g_number_of_points,
      g_with_byte_enable         => false,
      g_addr_conflict_resolution => "dont_care",
      g_init_file                => g_sin_file,
      g_dual_clock               => false
      )
    port map (
      rst_n_i => rst_n_i,
      clka_i  => clk_i,
      bwea_i  => (others => '0'),
      wea_i   => '0',
      aa_i    => cur_address,
      da_i    => (others => '0'),
      clkb_i  => clk_i,
      ab_i    => cur_address,
      qb_o    => sin_o
      );

  cmp_cos_lut : generic_simple_dpram
    generic map (
      g_data_width               => g_output_width,
      g_size                     => g_number_of_points,
      g_with_byte_enable         => false,
      g_addr_conflict_resolution => "dont_care",
      g_init_file                => g_cos_file,
      g_dual_clock               => false
      )
    port map (
      rst_n_i => rst_n_i,
      clka_i  => clk_i,
      bwea_i  => (others => '0'),
      wea_i   => '0',
      aa_i    => cur_address,
      da_i    => (others => '0'),
      clkb_i  => clk_i,
      ab_i    => cur_address,
      qb_o    => cos_o
      );

  cmp_sweep : lut_sweep
    generic map (
      g_bus_size      => c_bus_size,
      g_first_address => 0,
      g_last_address  => g_number_of_points-1,
      g_sweep_mode    => "sawtooth")
    port map (
      rst_n_i => rst_n_i,
      clk_i   => clk_i,
      ce_i      => ce_i,
      address_o => cur_address);

end architecture str;

-------------------------------------------------------------------------------
