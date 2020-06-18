import React, { Component } from 'react'

class StoreHeader extends Component {
  render() {
    return (
      <div className='store-header'>
        <div className='breabcrum' onClick={() => this.props.toggleActiveSub('')}>
          <i className="icon-chevron-left"></i>
          <span>Header</span>
        </div>

      </div>
    )
  }
}

export default StoreHeader