-- -------------------------------------------------------------
-- TablePlus 3.12.2(358)
--
-- https://tableplus.com/
--
-- Database: ta_search
-- Generation Time: 2021-02-13 11:30:05.2120
-- -------------------------------------------------------------


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


DROP TABLE IF EXISTS `tbl_rpt_list`;
CREATE TABLE `tbl_rpt_list` (
  `report` varchar(100) NOT NULL,
  `tbl_name` varchar(50) DEFAULT NULL,
  `report_db_type` varchar(20) DEFAULT NULL,
  `lineending` varchar(2) DEFAULT NULL,
  `request_interval` int DEFAULT NULL,
  `start_date_offset_hours` int DEFAULT NULL,
  `dont_request` tinyint(1) DEFAULT NULL,
  `okay_latest` tinyint(1) DEFAULT NULL,
  `notes` blob,
  `days_add` int DEFAULT NULL,
  PRIMARY KEY (`report`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `tbl_rpt_log`;
CREATE TABLE `tbl_rpt_log` (
  `user` varchar(50) NOT NULL,
  `report` varchar(50) NOT NULL,
  `report_id` varchar(20) DEFAULT NULL,
  `run_interval` int DEFAULT NULL,
  `last_run` datetime DEFAULT NULL,
  `active` tinyint(1) DEFAULT NULL,
  `cron` tinyint(1) DEFAULT NULL,
  `daily_3am` tinyint(1) DEFAULT NULL,
  `use_latest` tinyint(1) DEFAULT NULL,
  `notes` blob,
  PRIMARY KEY (`user`,`report`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `tbl_user_keys`;
CREATE TABLE `tbl_user_keys` (
  `user` varchar(20) DEFAULT NULL,
  `sellerid` varchar(20) DEFAULT NULL,
  `authtoken` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `tbl_rpt_list` (`report`, `tbl_name`, `report_db_type`, `lineending`, `request_interval`, `start_date_offset_hours`, `dont_request`, `okay_latest`, `notes`, `days_add`) VALUES
('_GET_AFN_INVENTORY_DATA_', 'tbl_rpt_GET_AFN_INVENTORY_DATA_', '', 'rn', '30', NULL, NULL, '0', 'FBA Invetory by condition. Tracks QTY Avialable', NULL),
('_GET_AMAZON_FULFILLED_SHIPMENTS_DATA_', 'tbl_rpt_GET_AMAZON_FULFILLED_SHIPMENTS_DATA_', 'OrdersDupeUpdate', 'rn', '30', '720', NULL, '0', 'good excep for first row error.  Tracking info for FBA orders', '510'),
('_GET_FBA_ESTIMATED_FBA_FEES_TXT_DATA_', 'tbl_rpt_GET_FBA_ESTIMATED_FBA_FEES_TXT_DATA_', '', 'rn', '240', '72', NULL, '0', 'good - are per page report generated every 72 hours, so set start back back and dont request often', NULL),
('_GET_FBA_FULFILLMENT_CUSTOMER_RETURNS_DATA_', 'tbl_rpt_GET_FBA_FULFILLMENT_CUSTOMER_RETURNS_DATA_', 'OrdersDupeUpdate', 'n', '30', '240', NULL, '0', 'good - daily. Read 10 days back to pick up any updates', NULL),
('_GET_FBA_FULFILLMENT_INVENTORY_HEALTH_DATA_', 'tbl_rpt_GET_FBA_FULFILLMENT_INVENTORY_HEALTH_DATA_', '', 'n', '30', '72', '0', '0', 'good - daily has lag - snapshot date so removed truncate and added snapshot date to key', NULL),
('_GET_FBA_FULFILLMENT_REMOVAL_ORDER_DETAIL_DATA_', 'tbl_rpt_GET_FBA_FULFILLMENT_REMOVAL_ORDER_DETAIL_D', 'OrdersDupeUpdate', 'n', '30', '720', NULL, '0', 'good - one tools requests at 90 days, one at 3 days  3 days can often return no data and grabbing values from other', NULL),
('_GET_FBA_INVENTORY_AGED_DATA_', 'tbl_rpt_GET_FBA_INVENTORY_AGED_DATA_', '', 'n', '30', NULL, NULL, '0', 'good - daily - has snapshot date so removed truncate', NULL),
('_GET_FBA_MYI_UNSUPPRESSED_INVENTORY_DATA_', 'tbl_rpt_GET_FBA_MYI_UNSUPPRESSED_INVENTORY_DATA_', '', 'rn', '30', NULL, NULL, '0', 'good - realtime', NULL),
('_GET_FBA_REIMBURSEMENTS_DATA_', 'tbl_rpt_GET_FBA_REIMBURSEMENTS_DATA_', 'OrdersDupeUpdate', 'rn', '30', '72', NULL, '0', 'good - daily one task runs 30 days back one 72', NULL),
('_GET_FLAT_FILE_ALL_ORDERS_DATA_BY_LAST_UPDATE_', 'tbl_rpt_GET_FLAT_FILE_ALL_ORDERS_DATA_BY_LAST_UPDA', '', 'rn', '30', '720', NULL, '0', 'NEED TO ADD UPDATE LOGIC', '1980'),
('_GET_FLAT_FILE_OPEN_LISTINGS_DATA_', 'tbl_rpt_GET_FLAT_FILE_OPEN_LISTINGS_DATA_', '', 'rn', '30', NULL, NULL, '0', 'Good - does not seem to have much data, just listing price.  Not requested often by other tasks', NULL),
('_GET_MERCHANT_LISTINGS_DATA_', 'tbl_rpt_GET_MERCHANT_LISTINGS_DATA_', '', 'n', '30', NULL, NULL, '1', 'Good', NULL),
('_GET_MERCHANT_LISTINGS_DATA_LITE_', 'tbl_rpt_GET_MERCHANT_LISTINGS_DATA_LITE_', '', 'n', '30', NULL, NULL, '0', 'I think this report my be depricated.  Either that or for merchant fufilled', NULL),
('_GET_RESERVED_INVENTORY_DATA_', 'tbl_rpt_GET_RESERVED_INVENTORY_DATA_', '', 'n', '30', NULL, NULL, '0', NULL, NULL),
('_GET_V2_SETTLEMENT_REPORT_DATA_FLAT_FILE_V2_', 'tbl_rpt_GET_V2_SETTLEMENT_REPORT_DATA_FLAT_FILE_V2', NULL, 'n', '30', NULL, '1', '0', NULL, NULL);

INSERT INTO `tbl_rpt_log` (`user`, `report`, `report_id`, `run_interval`, `last_run`, `active`, `cron`, `daily_3am`, `use_latest`, `notes`) VALUES
('dave', '_GET_AFN_INVENTORY_DATA_', '14', '5', '2021-02-12 22:10:31', '0', '0', '1', NULL, NULL),
('dave', '_GET_AMAZON_FULFILLED_SHIPMENTS_DATA_', '5', '600', '2021-02-12 22:11:31', '0', '0', '1', NULL, NULL),
('dave', '_GET_FBA_ESTIMATED_FBA_FEES_TXT_DATA_', '18610699813018277', '600', '2020-01-16 07:21:28', '0', '0', '0', NULL, NULL),
('dave', '_GET_FBA_FULFILLMENT_CUSTOMER_RETURNS_DATA_', '10', '600', '2021-02-12 22:06:31', '0', '0', '1', NULL, NULL),
('dave', '_GET_FBA_REIMBURSEMENTS_DATA_', '16', '600', '2021-02-12 22:09:31', NULL, NULL, '1', NULL, NULL),
('dave', '_GET_FLAT_FILE_ALL_ORDERS_DATA_BY_LAST_UPDATE_', '26', '600', '2021-02-12 22:12:31', '0', '0', '1', NULL, NULL),
('dave', '_GET_MERCHANT_LISTINGS_DATA_', '15', '5', '2021-02-12 22:11:31', '0', '0', '1', NULL, NULL),
('jordanna', '_GET_AFN_INVENTORY_DATA_', '25', '5', '2021-02-12 22:10:31', '0', '0', '1', NULL, NULL),
('jordanna', '_GET_AMAZON_FULFILLED_SHIPMENTS_DATA_', '29', '600', '2021-02-12 22:18:31', '0', '0', '1', NULL, NULL),
('jordanna', '_GET_FBA_ESTIMATED_FBA_FEES_TXT_DATA_', '18616710990018277', '600', '2020-01-16 07:19:21', '0', '0', '0', NULL, NULL),
('jordanna', '_GET_FBA_FULFILLMENT_CUSTOMER_RETURNS_DATA_', '17', '600', '2021-02-12 22:07:31', '0', '0', '1', NULL, NULL),
('jordanna', '_GET_FBA_REIMBURSEMENTS_DATA_', '6', '600', '2021-02-12 22:04:31', '0', '0', '1', NULL, NULL),
('jordanna', '_GET_FLAT_FILE_ALL_ORDERS_DATA_BY_LAST_UPDATE_', '19', '60', '2021-02-12 22:07:31', '0', '0', '1', NULL, NULL),
('jordanna', '_GET_FLAT_FILE_OPEN_LISTINGS_DATA_', '9', '30', '2021-02-12 22:07:31', '0', '0', '1', NULL, NULL),
('jordanna', '_GET_MERCHANT_LISTINGS_DATA_', '27', '5', '2021-02-12 22:12:31', '1', '0', '1', NULL, NULL),
('mikew', '_GET_AFN_INVENTORY_DATA_', '33', '5', '2021-02-12 22:16:31', '0', '0', '1', NULL, NULL),
('mikew', '_GET_AMAZON_FULFILLED_SHIPMENTS_DATA_', '3', '600', '2021-02-12 22:07:31', '0', '0', '1', NULL, NULL),
('mikew', '_GET_FBA_ESTIMATED_FBA_FEES_TXT_DATA_', '18606209327018277', '600', '2020-01-16 07:19:53', '0', '0', '0', NULL, NULL),
('mikew', '_GET_FBA_FULFILLMENT_CUSTOMER_RETURNS_DATA_', '20', '60', '2021-02-12 22:07:31', '0', '0', '1', NULL, NULL),
('mikew', '_GET_FBA_REIMBURSEMENTS_DATA_', '4', '600', '2021-02-12 22:04:31', NULL, NULL, '1', NULL, NULL),
('mikew', '_GET_MERCHANT_LISTINGS_DATA_', '32', '5', '2021-02-12 22:14:31', '1', '0', '1', NULL, NULL),
('paulw', '_GET_AFN_INVENTORY_DATA_', '11', '5', '2021-02-12 22:07:31', '0', '0', '1', NULL, NULL),
('paulw', '_GET_AMAZON_FULFILLED_SHIPMENTS_DATA_', '22', '600', '2021-02-12 22:17:31', '0', '0', '1', NULL, NULL),
('paulw', '_GET_FBA_ESTIMATED_FBA_FEES_TXT_DATA_', '18608941690018277', '600', '2020-01-16 07:03:17', '0', '0', '0', NULL, NULL),
('paulw', '_GET_FBA_FULFILLMENT_CUSTOMER_RETURNS_DATA_', '7', '600', '2021-02-12 22:11:31', '0', '0', '1', NULL, NULL),
('paulw', '_GET_FBA_REIMBURSEMENTS_DATA_', '31', '600', '2021-02-12 22:16:31', '0', '0', '1', NULL, NULL),
('paulw', '_GET_FLAT_FILE_OPEN_LISTINGS_DATA_', '18', '30', '2021-02-12 22:07:31', '0', '0', '1', NULL, NULL),
('paulw', '_GET_MERCHANT_LISTINGS_DATA_', '13', '5', '2021-02-12 22:12:31', '0', '0', '1', NULL, NULL),
('personalt', '_GET_AFN_INVENTORY_DATA_', '23', '60', '2021-02-12 22:08:31', '0', '0', '1', NULL, NULL),
('personalt', '_GET_AMAZON_FULFILLED_SHIPMENTS_DATA_', '28', '600', '2021-02-12 22:17:31', '0', '0', '1', NULL, NULL),
('personalt', '_GET_FBA_ESTIMATED_FBA_FEES_TXT_DATA_', NULL, '600', '2020-01-16 07:26:37', '0', '0', '0', NULL, NULL),
('personalt', '_GET_FBA_FULFILLMENT_CUSTOMER_RETURNS_DATA_', '30', '600', '2021-02-12 22:26:31', '0', '0', '1', NULL, NULL),
('personalt', '_GET_FBA_FULFILLMENT_INVENTORY_HEALTH_DATA_', NULL, '600', '2019-12-07 13:15:35', '0', '0', '0', NULL, NULL),
('personalt', '_GET_FBA_FULFILLMENT_REMOVAL_ORDER_DETAIL_DATA_', '1', '600', '2021-02-12 22:05:31', '0', '0', '1', NULL, NULL),
('personalt', '_GET_FBA_INVENTORY_AGED_DATA_', '2', '600', '2021-02-12 22:09:31', '0', '0', '1', NULL, NULL),
('personalt', '_GET_FBA_MYI_UNSUPPRESSED_INVENTORY_DATA_', '16681485575018158', '600', '2019-09-19 01:03:38', '0', '0', '0', NULL, NULL),
('personalt', '_GET_FBA_REIMBURSEMENTS_DATA_', '8', '600', '2021-02-12 22:04:31', '0', '0', '1', NULL, NULL),
('personalt', '_GET_FLAT_FILE_ALL_ORDERS_DATA_BY_LAST_UPDATE_', '18611404144018277', '120', '2020-01-16 08:38:33', '0', '0', '0', NULL, NULL),
('personalt', '_GET_FLAT_FILE_OPEN_LISTINGS_DATA_', '21', '30', '2021-02-12 22:09:31', '0', '0', '1', NULL, NULL),
('personalt', '_GET_MERCHANT_LISTINGS_DATA_', '12', '5', '2021-02-12 22:06:31', '0', '0', '1', NULL, NULL),
('personalt', '_GET_RESERVED_INVENTORY_DATA_', '24', '60', '2021-02-12 22:10:31', '0', '0', '1', NULL, NULL),
('personalt', '_GET_V2_SETTLEMENT_REPORT_DATA_FLAT_FILE_V2_', '11307189540017792', '60', '2018-09-21 01:14:23', '0', '0', '0', '1', NULL);

INSERT INTO `tbl_user_keys` (`user`, `sellerid`, `authtoken`) VALUES
('personalt', '111', 'abc'),
('paulw', '222', 'def'),
('jordanna', '333', 'hik'),
('mikew', '444', 'lmn'),
('dave', '555', 'opq');



/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;