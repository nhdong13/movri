import React, { Component } from 'react'
import StoreSections from '../../composites/StoreSections'

class OnlineStore extends Component {
 render() {
   return (
     <div>
       <StoreSections defaultSections={this.props.default_sections}/>
     </div>
   )
 }
}

export default OnlineStore