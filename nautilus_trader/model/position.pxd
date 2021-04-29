# -------------------------------------------------------------------------------------------------
#  Copyright (C) 2015-2021 Nautech Systems Pty Ltd. All rights reserved.
#  https://nautechsystems.io
#
#  Licensed under the GNU Lesser General Public License Version 3.0 (the "License");
#  You may not use this file except in compliance with the License.
#  You may obtain a copy of the License at https://www.gnu.org/licenses/lgpl-3.0.en.html
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# -------------------------------------------------------------------------------------------------

from decimal import Decimal

from libc.stdint cimport int64_t

from nautilus_trader.model.c_enums.order_side cimport OrderSide
from nautilus_trader.model.c_enums.position_side cimport PositionSide
from nautilus_trader.model.currency cimport Currency
from nautilus_trader.model.events cimport OrderFilled
from nautilus_trader.model.identifiers cimport AccountId
from nautilus_trader.model.identifiers cimport ClientOrderId
from nautilus_trader.model.identifiers cimport ExecutionId
from nautilus_trader.model.identifiers cimport InstrumentId
from nautilus_trader.model.identifiers cimport PositionId
from nautilus_trader.model.identifiers cimport StrategyId
from nautilus_trader.model.objects cimport Money
from nautilus_trader.model.objects cimport Price
from nautilus_trader.model.objects cimport Quantity


cdef class Position:
    cdef list _events
    cdef list _execution_ids
    cdef object _buy_qty
    cdef object _sell_qty
    cdef dict _commissions

    cdef readonly PositionId id
    """The positions identifier.This may be generated by the exchange/brokerage, or can be system
        generated depending on `Order Management System (OMS)` settings.\n\n\n:returns: `PositionId`"""
    cdef readonly AccountId account_id
    """The account identifier associated with the position.\n\n:returns: `AccountId`"""
    cdef readonly ClientOrderId from_order
    """The client order identifier for the order which first opened the position.\n\n:returns: `ClientOrderId`"""
    cdef readonly StrategyId strategy_id
    """The strategy identifier associated with the position.\n\n:returns: `StrategyId`"""
    cdef readonly InstrumentId instrument_id
    """The position instrument identifier.\n\n:returns: `InstrumentId`"""
    cdef readonly OrderSide entry
    """The entry direction from open.\n\n:returns: `OrderSide`"""
    cdef readonly PositionSide side
    """The current position side.\n\n:returns: `PositionSide`"""
    cdef readonly object relative_qty
    """The relative quantity (positive for LONG, negative for SHORT).\n\n:returns: `Decimal`"""
    cdef readonly Quantity quantity
    """The current open quantity.\n\n:returns: `Quantity`"""
    cdef readonly Quantity peak_qty
    """The peak directional quantity reached by the position.\n\n:returns: `Quantity`"""
    cdef readonly Currency quote_currency
    """The position quote currency.\n\n:returns: `Currency`"""
    cdef readonly bint is_inverse
    """If the quantity is expressed in quote currency.\n\n:returns: `bool`"""
    cdef readonly int64_t timestamp_ns
    """The position initialization Unix timestamp (nanoseconds).\n\n:returns: `int64`"""
    cdef readonly int64_t opened_timestamp_ns
    """The opened time Unix timestamp (nanoseconds).\n\n:returns: `int64`"""
    cdef readonly int64_t closed_timestamp_ns
    """The closed time Unix timestamp (nanoseconds).\n\n:returns: `int64`"""
    cdef readonly int64_t open_duration_ns
    """The total open duration (nanoseconds).\n\n:returns: `int64`"""
    cdef readonly object avg_px_open
    """The average open price.\n\n:returns: `Decimal`"""
    cdef readonly object avg_px_close
    """The average closing price.\n\n:returns: `Decimal` or `None`"""
    cdef readonly object realized_points
    """The realized points of the position.\n\n:returns: `Decimal`"""
    cdef readonly object realized_return
    """The realized return of the position.\n\n:returns: `Decimal`"""
    cdef readonly Money realized_pnl
    """The realized PnL of the position (including commission).\n\n:returns: `Money`"""
    cdef readonly Money commission
    """The commission generated by the position in quote currency.\n\n:returns: `Money`"""

    cdef list client_order_ids_c(self)
    cdef list venue_order_ids_c(self)
    cdef list execution_ids_c(self)
    cdef list events_c(self)
    cdef OrderFilled last_event_c(self)
    cdef ExecutionId last_execution_id_c(self)
    cdef int event_count_c(self) except *
    cdef str status_string_c(self)
    cdef bint is_long_c(self) except *
    cdef bint is_short_c(self) except *
    cdef bint is_open_c(self) except *
    cdef bint is_closed_c(self) except *

    @staticmethod
    cdef inline PositionSide side_from_order_side_c(OrderSide side) except *

    cpdef void apply(self, OrderFilled fill) except *

    cpdef Money notional_value(self, Price last)
    cpdef Money calculate_pnl(self, avg_px_open: Decimal, avg_px_close: Decimal, quantity: Decimal)
    cpdef Money unrealized_pnl(self, Price last)
    cpdef Money total_pnl(self, Price last)
    cpdef list commissions(self)

    cdef inline void _handle_buy_order_fill(self, OrderFilled fill) except *
    cdef inline void _handle_sell_order_fill(self, OrderFilled fill) except *
    cdef inline object _calculate_avg_px(self, avg_px: Decimal, qty: Decimal, OrderFilled fill)
    cdef inline object _calculate_avg_px_open_px(self, OrderFilled fill)
    cdef inline object _calculate_avg_px_close_px(self, OrderFilled fill)
    cdef inline object _calculate_points(self, avg_px_open: Decimal, avg_px_close: Decimal)
    cdef inline object _calculate_points_inverse(self, avg_px_open: Decimal, avg_px_close: Decimal)
    cdef inline object _calculate_return(self, avg_px_open: Decimal, avg_px_close: Decimal)
    cdef inline object _calculate_pnl(self, avg_px_open: Decimal, avg_px_close: Decimal, quantity: Decimal)
