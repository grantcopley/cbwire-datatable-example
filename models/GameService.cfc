component {

    property name="wirebox" inject="wirebox";

    /**
     * Favorite games.
     */
    function favoriteByIds( array ids ) {
        wirebox.getInstance('QueryBuilder@qb')
            .from( "nes_games" )
            .whereIn( "id", ids )
            .update( {
                "favorite": 1
            } );
    }

    /**
     * Clear favorites.
     */
    function clearFavorites() {
        wirebox.getInstance('QueryBuilder@qb')
            .from( "nes_games" )
            .update( {
                "favorite": 0
            } );        
    }

    /**
     * Get by ids.
     */
    function getByIDs( array ids ) {
        return wirebox.getInstance('QueryBuilder@qb')
                        .from( "nes_games" )
                        .whereIn( "id", ids )
                        .get();
    }

    /**
     * Get with filters
     */
    function search( filters = {} ) {
        if ( structKeyExists( variables, "_games" ) ) {
            return variables._games;
        }
        variables._games = wirebox.getInstance('QueryBuilder@qb')
                    .from( "nes_games")
                    .when( len( filters.searchTerm ), function( q ) {
                        q.where( "id", "=", filters.searchTerm )
                            .orWhere( "game", "like", "%#trim( filters.searchTerm )#%" )
                            .orWhere( "publisher", "like", "%#trim( filters.searchTerm )#%" )
                            .orWhere( "license", "like", "%#trim( filters.searchTerm )#%" )
                            .orWhere( "rarity", "like", "%#trim( filters.searchTerm )#%" );
                    } )
                    .limit( filters.limit )
                    .orderBy( filters.sortBy & " " & filters.sortDirection )
                    .paginate( filters.page, filters.limit );

        return variables._games;
    }

}