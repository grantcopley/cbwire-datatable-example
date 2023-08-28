<cfscript>

    /**
     * Customer service
     */
    property name="customerService" inject="CustomerService";

    /**
     * Data properties
     */
    data = {
        "limit": 10,
        "page": 1,
        "searchTerm": "",
        "sortBy": "firstname",
        "sortDirection": "asc",
        "selectAllBtn": false,
        "selected": [],
        "deleting": false
    };

    /**
     * Lifecycle actions
     */
    function onUpdateLimit() {
        reset( "page" );
    }

    function onUpdateSearchTerm() {
        reset( "page" );
    }

    function onUpdateSelectAllBtn() {
        data.selected = [];
        if ( data.selectAllBtn ) {
            data.selected = currentCustomerResults().map( function( customer ) {
                return customer.id
            } );
        }
    }

    /**
     * Actions
     */
    function startOver() {
        reset();
    }

    function paginate( page ) {
        data.page = arguments.page;
    }

    function nextPage() {
        data.page += 1;
    }

    function previousPage() {
        if ( data.page == 1 ) return;
        data.page -= 1;
    }

    function sortCustomers( column ) {
        if ( data.sortBy == arguments.column ) {
            // already sorting, so change the sortDirection
            toggleSortDirection();
        } else {
            data.sortBy = arguments.column;
        }
    }

    function toggleSortDirection() {
        data.sortDirection = ( data.sortDirection == "asc" ? "desc" : "asc" );
    }

    function toggleSelect( id ) {
        var index = arrayFindNoCase( data.selected, id );
        if ( index ) {
            arrayDeleteAt( data.selected, index );
        } else {
            arrayAppend( data.selected, id );
        }
    }

    function confirmDelete() {
        data.deleting = true;
    }

    function cancelDelete() {
        reset( "deleting" );
    }

    function deleteSelected() {
        customerService.deleteByIds( data.selected );
        reset( "deleting" );
        reset( "searchTerm" );
        reset( "selected" );
        reset( "selectAllBtn" );
    }

    function selectBox( id, isChecked, pressedShift ) {
        if ( isChecked ) {
            data.selected.append( id );
            if ( arguments.pressedShift ) {

                var customerIndex = currentCustomerResults().reduce( function( agg, customer, i ) {
                    if ( customer.id == id ) {
                        agg = i;
                    }
                    return agg;
                }, 0 );

                for ( var i = customerIndex-1; i>=1; i-- ) {
                    var customer = currentCustomerResults()[ i ];
                    if ( !arrayFindNoCase( data.selected, customer.id ) ) {
                        data.selected.append( customer.id );
                    } else {
                        break;
                    }
                }
            }
        } else {
            var index = arrayFindNoCase( data.selected, id );
            if ( arrayFindNoCase( data.selected, id ) ) {
                arrayDeleteAt( data.selected, index );
                if ( arguments.pressedshift ) {
                    data.selected = [];
                }
            }
        }
    }

    function seedDatabase() {
        customerService.seedDatabase();        
    }

    /** Additional methods **/
    function currentCustomers() {
        return customerService.search( filters=data )
    }

    function currentCustomerResults() {
        return currentCustomers().results;
    }

    function selectedCustomers() {
        return customerService.getByIDs( data.selected );
    }

    function pagination() {
        return currentCustomers().pagination;
    }

    function totalRecords() {
        return pagination().totalRecords;
    }

    function totalPages() {
        return pagination().totalPages;
    }

    function startPaginationAt() {
        var startAt = data.page - 3;
        return startAt <= 0 ? 1 : startAt;
    }
    
    function endPaginationAt() {
        var endAt = startPaginationAt() + 6;
        if ( endAt > pagination().totalPages ) {
            endAt = pagination().totalPages;
        }
        return endAt;
    }

    function startRecordAt() {
        if ( data.page == 1 ) return 1;
        return ( data.page * data.limit ) - data.limit + 1;
    }

    function endRecordAt() {
        return startRecordAt() + data.limit - 1;
    }
</cfscript>

<cfoutput>
    <div x-data="{
        limit: #entangle( 'limit' )#,
        sortDirection: #entangle( 'sortDirection' )#,
        selected: #entangle( 'selected' )#,
        selectAllBtn: #entangle( 'selectAllBtn' )#,
        clickHandler: function( event ) {
            $wire.selectBox( 
                event.target.value,
                event.target.checked,
                event.shiftKey
            );               
        }
    }">

        <div class="row align-items-center">
            <div class="col">
                <h1>CBWIRE DataTable</h1>
            </div>
            <div class="col text-end">
                Powered by caffeine and <a href="https://cbwire.ortusbooks.com">CBWIRE</a>.
            </div>
        </div>


        <cfif deleting>
            <div class="mt-3">
                Are you sure you want to remove theses <strong>#arrayLen( selected )# customer(s)</strong>?
            </div>
            <div class="mt-3">
                <ul>
                    <cfloop array="#selectedCustomers()#" index="customer">
                        <li>#customer.firstname# #customer.lastname# (#customer.company#) &lt;#customer.email#&gt;</li>
                    </cfloop>
                </ul>
            </div>
            <div class="mt-3">
                <button 
                    wire:click="deleteSelected"
                    class="btn btn-primary">Delete</button>

                <button 
                    wire:click="cancelDelete"
                    class="btn btn-secondary">Cancel</button>
            </div>
        <cfelse>
            <div class="mt-3">
                <div class="row">
                    <div class="col">
                        Display:
                        <select wire:model="limit">
                            <option value="10">10</option>
                            <option value="20">20</option>
                            <option value="50">50</option>
                        </select>
                        <span wire:loading>...</span>
                    </div>
                    <div class="col">
                        <input
                            wire:model.debounce.500ms="searchTerm"
                            type="text"
                            class="form-control"
                            placeholder="Search columns">
                    </div>
                </div>
            </div>
    
            <cfif arrayLen( currentCustomerResults() )>
                <div>
                    <button 
                        wire:click="confirmDelete"
                        class="btn btn-danger btn-sm" <cfif not arrayLen( selected )>disabled</cfif>>Delete<cfif arrayLen( selected )> (#arrayLen( selected )#)</cfif></button>

                    <button 
                        wire:click="startOver"
                        class="btn btn-secondary btn-link">Reset</button>
                </div>
                <table class="table table-hover">
                    <thead>
                        <th style="width: 5%;">
                            <input type="checkbox" x-model="selectAllBtn" value="true">
                        </th>
                        <th style="width: 22%;"><a wire:click.prevent="sortCustomers( 'firstname' )" href="##">Firstname</a></th>
                        <th style="width: 22%;"><a wire:click.prevent="sortCustomers( 'lastname' )" href="##">Lastname</a></th>
                        <th style="width: 22%;"><a wire:click.prevent="sortCustomers( 'company' )" href="##">Company</a></th>
                        <th style="width: 22%;"><a wire:click.prevent="sortCustomers( 'email' )" href="##">Email</a></th>
                    </thead>
                    <tbody>
                        <cfloop array="#currentCustomerResults()#" index="customer">
                            <tr>
                                <td>
                                    <input type="checkbox" x-model="selected" value="#customer.id#" @click.prevent="clickHandler( $event )">
                                </td>
                                <td wire:click="toggleSelect( '#customer.id#' )">#customer.firstname#</td>
                                <td wire:click="toggleSelect( '#customer.id#' )">#customer.lastname#</td>
                                <td wire:click="toggleSelect( '#customer.id#' )">#customer.company#</td>
                                <td wire:click="toggleSelect( '#customer.id#' )">#customer.email#</td>
                            </tr>
                        </cfloop>
                    </tbody>
                </table>
        
                <nav aria-label="Page navigation example">
                    <ul class="pagination">
                        <cfloop from="#startPaginationAt()#" to="#endPaginationAt()#" index="i">
                            <li class="page-item <cfif i eq page>active</cfif>"><a wire:click.prevent="paginate( #i# )" class="page-link" href="##">#i#</a></li>
                        </cfloop>
                        <li class="page-item"><a wire:click.prevent="startOver" class="page-link" href="##">Reset</a></li>
                    </ul>
                </nav>
                <div class="mb-3">
                    Showing #startRecordAt()# to #endRecordAt()# of #totalRecords()# records ( #totalPages()# pages )
                </div>
            <cfelse>
                <div class="mb-3">
                    No records found.
                </div>
            </cfif>
        </cfif>
    </div>
</cfoutput>