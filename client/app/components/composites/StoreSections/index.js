import React, { Component } from 'react'
import StoreHeader from '../StoreHeader'

class StoreSections extends Component {
  constructor(props) {
    super(props)
    this.toggleActiveSub = this.toggleActiveSub.bind(this)
    this.state = {
      activeSub: null
    }
  }

  toggleActiveSub(value) {
    this.setState({activeSub: value})
  }

  renderContent() {
    switch(this.state.activeSub) {
      case 'header':
        return <StoreHeader toggleActiveSub={this.toggleActiveSub}/>
      default:
        return (
          <div>
            <h1>Store Sections</h1>
            <ul className='section-list'>
              {
                this.props.defaultSections.map(item => {
                  return (
                    <li className='section-item' key={item} onClick={(e) => this.toggleActiveSub(item)}>
                      <div className='title'>{item}</div>
                    </li>
                  )
                })
              }
            </ul>
          </div>
        )
    }
  }

  render() {
    console.log(this.state.activeSub)
    return (
      <div className='store-sections'>
        { this.renderContent() }
      </div>
    )
  }
}

export default StoreSections