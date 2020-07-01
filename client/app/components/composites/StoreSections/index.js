import React, { Component } from 'react'
import { connect } from 'react-redux'
import axios from 'axios'
import StoreHeader from '../StoreHeader'
import Slideshow from '../Slideshow'
import HighlightBanner from '../HighlightBanner'
import SectionMore from '../SectionMore'
import StoreCategoryList from '../StoreCategoryList'
import StoreFeaturedList from '../StoreFeaturedList'

import { onlineStoreActions } from '../../../actions/OnlineStoreActions'


class StoreSections extends Component {
  constructor(props) {
    super(props)

    this.toggleActiveSub = this.toggleActiveSub.bind(this)
    this.addMoreSection = this.addMoreSection.bind(this)
    this.closeMoreSection = this.closeMoreSection.bind(this)
    this.handleAddSectionSubmit = this.handleAddSectionSubmit.bind(this)

    this.state = {
      activeSub: null,
      lightboxMe: undefined,
      alertMessage: '',
      alertDisplayed: false,
      sectionAdding: false
    }
  }

  componentDidMount() {
    // $('#store-section-form').submit(e => {
    //   e.preventDefault()
    //   let url = e.target.action
    //   this.handleAddSectionSubmit({url: url, name: $(e.target).find('#name').val()})
    //   return false
    // })
  }

  toggleActiveSub(value) {
    this.setState({activeSub: value})
  }

  handleAddSectionSubmit(options) {
    // let data = {
    //   name: options.name
    // }
    // axios.post(options.url, data).then(res => {
    //   if (res.status == 200 && res.data.success) {
    //     let item = res.data.item
    //     this.props.addSectionItem(item)
    //   } else {
    //     this.setState({
    //       alertDisplayed: true,
    //       alertMessage: res.data.message
    //     })
    //   }
    //   this.state.lightboxMe.trigger('close')
    // })
  }

  addMoreSection() {
    this.setState({
      sectionAdding: true
    })
  }

  closeMoreSection() {
    this.setState({
      sectionAdding: false
    })
  }

  renderContent() {
    let item  = this.state.activeSub
    if (this.state.sectionAdding) {
      return <SectionMore closeMoreSection={this.closeMoreSection}/>
    }
    switch(item && item.name) {
      case 'Header':
        return <StoreHeader toggleActiveSub={this.toggleActiveSub} object={item.object}/>
      case 'Slideshow':
        return <Slideshow toggleActiveSub={this.toggleActiveSub} object={item.object}/>
      case 'HighlightBanner':
        return <HighlightBanner toggleActiveSub={this.toggleActiveSub} object={item.object}/>
      case 'StoreCategory':
        return <StoreCategoryList callback={this.toggleActiveSub} object={item.object}/>
      case 'FeaturedList':
        return <StoreFeaturedList callback={this.toggleActiveSub} object={item.object}/>
      default:
        return (
          <div>
            <h1 className='p-3'>Store Sections</h1>
            <ul className='section-list'>
              {
                this.props.sections.map(item => {
                  return (
                    <li className='section-item' key={item.id} onClick={(e) => this.toggleActiveSub(item)}>
                      <div className='title'>{item.object.heading || item.name}</div>
                    </li>
                  )
                })
              }
            </ul>
            <button className='btn p-2' onClick={this.addMoreSection}>Add section</button>
          </div>
        )
    }
  }

  render() { 
    return (
      <div className='store-sections'>
        { this.state.alertDisplayed && <div className='flash-icon ss-info'>{this.state.alertMessage}</div> }
        { this.renderContent() }
      </div>
    )
  }
}

StoreSections.defaultProps = {
  sections: []
}

const mapStateToProps = (state) => {
  return {
    sections: state.onlineStore.sections,
  };
};

const mapDispatchToProps = {
  addSectionItem: onlineStoreActions.addSectionItem
}

export default connect(mapStateToProps, mapDispatchToProps)(StoreSections)