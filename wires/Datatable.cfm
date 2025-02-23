<cfoutput>
    <div x-data="{
        limit: $wire.limit,
        sortDirection: $wire.sortDirection,
        selected: $wire.selected,
        selectAllBtn: $wire.selectAllBtn,
        async clickHandler( event ) {
            await $wire.selectBox( 
                event.target.value,
                event.target.checked,
                event.shiftKey
            )

            if ( event.target.checked ) {
                this.selected.push( event.target.value )
            } else {
                this.selected.filter( id => id != event.target.value ) 
            }
        },
        async selectAllHandler( event ) {
            $wire.selectAllBtn = event.target.checked
            await $wire.$refresh()
            this.selected = $wire.selected
        }
    }">
        <div class="row align-items-center">
            <div class="col">
                <h1>Favorite NES Games</h1>
            </div>
            <div class="col text-end">
                Powered by caffeine and <a href="https://cbwire.ortusbooks.com">CBWIRE</a>.
            </div>
        </div>
        <cfif favoriting>
            <div class="mt-3">
                Are you sure you want to favorite theses <strong>#arrayLen( selected )# games(s)</strong>?
            </div>
            <div class="mt-3">
                <ul>
                    <cfloop array="#selectedGames()#" index="gameObj">
                        <li>#gameObj.game#</li>
                    </cfloop>
                </ul>
            </div>
            <div class="mt-3">
                <button 
                    wire:click="favoriteGames"
                    class="btn btn-primary">Favorite</button>

                <button 
                    wire:click="cancelConfirmFavorites"
                    class="btn btn-secondary">Cancel</button>
            </div>
        <cfelse>
            <div class="mt-3">
                <div class="row">
                    <div class="col">
                        Display:
                        <select wire:model.live="limit">
                            <option value="10">10 games</option>
                            <option value="20">20 games</option>
                            <option value="50">50 games</option>
                        </select>
                        <span wire:loading>...</span>
                    </div>
                    <div class="col">
                        <input
                            wire:model.live.debounce.500ms="searchTerm"
                            type="text"
                            class="form-control"
                            placeholder="Search columns">
                    </div>
                </div>
            </div>
    
            <cfif arrayLen( currentGameResults() )>
                <div>
                    <button 
                        wire:click="confirmFavorite"
                        class="btn btn-primary" <cfif not arrayLen( selected )>disabled</cfif>>Set Favorite<cfif arrayLen( selected )> (#arrayLen( selected )#)</cfif></button>

                    <button 
                        wire:click="removeFavorites"
                        class="btn btn-link">Reset Favorites</button>
                </div>
                <table class="table table-hover">
                    <thead>
                        <th style="width: 5%;">
                            <input type="checkbox" @click="selectAllHandler" value="true">
                        </th>
                        <th style="width: 22%;"><a wire:click.prevent="sortGames( 'game' )" href="##">Game</a></th>
                        <th style="width: 22%;"><a wire:click.prevent="sortGames( 'publisher' )" href="##">Publisher</a></th>
                        <th style="width: 22%;"><a wire:click.prevent="sortGames( 'license' )" href="##">License</a></th>
                        <th style="width: 22%;"><a wire:click.prevent="sortGames( 'rarity' )" href="##">Rarity</a></th>
                        <th style="width: 5%;"><a wire:click.prevent="sortGames( 'favorite' )" href="##">Favorite</a></th>
                    </thead>
                    <tbody>
                        <cfloop array="#currentGameResults()#" index="gameObj">
                            <tr>
                                <td>
                                    <input type="checkbox" x-model="selected" value="#gameObj.id#" @click="clickHandler( $event )">
                                </td>
                                <td wire:click="toggleSelect( '#gameObj.id#' )">#gameObj.game#</td>
                                <td wire:click="toggleSelect( '#gameObj.id#' )">#gameObj.publisher#</td>
                                <td wire:click="toggleSelect( '#gameObj.id#' )">#gameObj.license#</td>
                                <td wire:click="toggleSelect( '#gameObj.id#' )">#gameObj.rarity#</td>
                                <td wire:click="toggleSelect( '#gameObj.id#' )"><cfif gameObj.favorite><i class="fa-solid fa-star text-primary"></i></cfif></td>
                            </tr>
                        </cfloop>
                    </tbody>
                </table>
        
                <nav aria-label="Page navigation example">
                    <ul class="pagination">
                        <cfloop from="#startPaginationAt()#" to="#endPaginationAt()#" index="i">
                            <li class="page-item <cfif i eq page>active</cfif>"><a wire:click.prevent="changePage( #i# )" class="page-link" href="##">#i#</a></li>
                        </cfloop>
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

<cfscript>
    // @startWire
    /**
     * Game service
     */
    property name="gameService" inject="GameService";

    /**
     * Data properties
     */
    data = {
        "limit": 10,
        "page": 1,
        "searchTerm": "",
        "sortBy": "game",
        "sortDirection": "asc",
        "selectAllBtn": false,
        "selected": [],
        "favoriting": false
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
            data.selected = currentGameResults().map( function( game ) {
                return game.id
            } );
        }
    }

    /**
     * Actions
     */
    function removeFavorites() {
        gameService.clearFavorites();
        reset();
    }

    function changePage( page ) {
        data.page = arguments.page;
    }

    function sortGames( column ) {
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

    function confirmFavorite() {
        data.favoriting = true;
    }

    function cancelConfirmFavorites() {
        reset( "favoriting" );
    }

    function favoriteGames() {
        gameService.favoriteByIds( data.selected );
        reset( "favoriting" );
        reset( "searchTerm" );
        reset( "selected" );
        reset( "selectAllBtn" );
    }

    function selectBox( id, isChecked, pressedShift ) {
        if ( isChecked ) {
            data.selected.append( id );
            if ( arguments.pressedShift ) {

                var gameIndex = currentGameResults().reduce( function( agg, game, i ) {
                    if ( game.id == id ) {
                        agg = i;
                    }
                    return agg;
                }, 0 );

                for ( var i = gameIndex-1; i>=1; i-- ) {
                    var game = currentGameResults()[ i ];
                    if ( !arrayFindNoCase( data.selected, game.id ) ) {
                        data.selected.append( game.id );
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
        gameService.seedDatabase();        
    }

    /** Additional methods **/
    function currentGames() {
        return gameService.search( filters=data )
    }

    function currentGameResults() {
        return currentGames().results;
    }

    function selectedGames() {
        return gameService.getByIDs( data.selected );
    }

    function pagination() {
        return currentGames().pagination;
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
    // @endWire
</cfscript>