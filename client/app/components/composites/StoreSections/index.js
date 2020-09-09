import React, { Component, Fragment } from 'react'
import { connect } from 'react-redux'
import axios from 'axios'
import { onlineStoreActions } from '../../../actions/OnlineStoreActions'
import StoreHeader from '../StoreHeader'
import Slideshow from '../Slideshow'
import HighlightBanner from '../HighlightBanner'
import SectionMore from '../SectionMore'
import StoreCategoryList from '../StoreCategoryList'
import StoreFeaturedList from '../StoreFeaturedList'
import StoreGrid from '../StoreGrid'
import StoreFooter from '../StoreFooter'
import HelpfulLink from '../HelpfulLink'
import { sortByOrderNumber } from '../../../utils/common'
import {
  sortableContainer,
  sortableElement,
  sortableHandle,
} from 'react-sortable-hoc';
import arrayMove from 'array-move';
import _ from 'lodash';

const SortableItem = sortableElement(({item, content}) => {
  return (
    <Fragment>
      {content}
    </Fragment>
  )
});

const SortableContainer = sortableContainer(({children}) => {
  return <ul className='p-0'>{children}</ul>;
});

const DragHandle = sortableHandle(() => <span className='font-size-16'>::</span>);

class StoreSections extends Component {
  constructor(props) {
    super(props)

    this.toggleActiveSub = this.toggleActiveSub.bind(this)
    this.addMoreSection = this.addMoreSection.bind(this)
    this.closeMoreSection = this.closeMoreSection.bind(this)
    this.handleAddSectionSubmit = this.handleAddSectionSubmit.bind(this)
    this.onSortBodyEnd = this.onSortBodyEnd.bind(this)
    this.onSortFooterEnd = this.onSortFooterEnd.bind(this)

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

  onSortBodyEnd({oldIndex, newIndex}) {
    let bodySections = sortByOrderNumber(this.props.sections.filter(section => section.name !== "StoreFooter" && section.name !== "HelpfulLink" && section.name !== "Header" && section.name !== "Slideshow" && section.name !== 'HighlightBanner'))
    let newBodySections = arrayMove(bodySections, oldIndex, newIndex).map((item, index) => {
      return {...item, order_number: index + 1 }
    })

    let dataParams = {
      authenticity_token: $('input[name ="authenticity_token"]').val(),
      sections: newBodySections.map((section) => {return {id: section.id, order_number: section.order_number}})
    }

    const axiosOptions = {
      url: `/admin/online_stores/${this.props.onlineStore.id}/store_sections/sort_sections`,
      method: 'put',
      data: dataParams
    }

    axios(axiosOptions).then(res => {
      let sections = res.data.store.sections || []
      this.props.updateSectionsList(sections)
      $("#homepage-preview-iframe").attr("src", function(index, attr){ 
        return attr;
      });
    })
  }

  onSortFooterEnd({oldIndex, newIndex}) {
    let footerSections = sortByOrderNumber(this.props.sections.filter(section => section.name == "StoreFooter" || section.name == "HelpfulLink"))
    let newFooterSections = arrayMove(footerSections, oldIndex, newIndex).map((item, index) => {
      return {...item, order_number: index + 1 }
    })
    let dataParams = {
      authenticity_token: $('input[name ="authenticity_token"]').val(),
      sections: newFooterSections.map((section) => {return {id: section.id, order_number: section.order_number}})
    }
    const axiosOptions = {
      url: `/admin/online_stores/${this.props.onlineStore.id}/store_sections/sort_sections`,
      method: 'put',
      data: dataParams
    }
    axios(axiosOptions).then(res => {
      let sections = res.data.store.sections || []
      this.props.updateSectionsList(sections)
      $("#homepage-preview-iframe").attr("src", function(index, attr){ 
        return attr;
      });
    })
  }

  renderTitle(item) {
    return (item.object.heading || item.object.name || item.name)
  }

  renderContent() {
    let item  = this.state.activeSub
    let sections = this.props.sections || []
    let headerSections = sections.filter(section => section.name == 'Header')
    let slideshowSections = sections.filter(section => section.name == 'Slideshow')
    let highlightBannerSections = sections.filter(section => section.name == 'HighlightBanner')
    let footerSections = sortByOrderNumber(sections.filter(section => section.name == "StoreFooter" || section.name == "HelpfulLink"))
    let bodySections = sortByOrderNumber(sections.filter(section => section.name !== "StoreFooter" && section.name !== "HelpfulLink" && section.name !== "Header" && section.name !== "Slideshow" && section.name !== 'HighlightBanner'))
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
        return <StoreFeaturedList 
          callback={this.toggleActiveSub}
          section={item}/>
      case 'StoreGrid':
        return <StoreGrid 
          callback={this.toggleActiveSub}
          section={item}/>
      case 'StoreFooter':
        return <StoreFooter 
          callback={this.toggleActiveSub}
          section={item}/>
      case 'HelpfulLink':
        return <HelpfulLink 
          callback={this.toggleActiveSub}
          section={item}/>
      default:
        return (
          <div>
            <h1 className='p-3'>Store Sections</h1>
            <ul className='section-list'>
              {
                headerSections.map(item => {
                  return (
                    <li className='section-item' key={item.id} onClick={(e) => this.toggleActiveSub(item)}>
                      <div className='title'>{this.renderTitle(item)}</div>
                    </li>
                  )
                })
              }
              {
                slideshowSections.map(item => {
                  return (
                    <li className='section-item' key={item.id} onClick={(e) => this.toggleActiveSub(item)}>
                      <div className='title'>{this.renderTitle(item)}</div>
                    </li>
                  )
                })
              }
              {
                highlightBannerSections.map(item => {
                  return (
                    <li className='section-item' key={item.id} onClick={(e) => this.toggleActiveSub(item)}>
                      <div className='title'>{this.renderTitle(item)}</div>
                    </li>
                  )
                })
              }
              <SortableContainer onSortEnd={this.onSortBodyEnd} useDragHandle>
                {
                  bodySections.map((item, index) => (
                    <SortableItem
                      key={`section-item-${item.id}` || randomString()}
                      index={index}
                      item={item}
                      content={
                        <li key={`section-${item.id}`} className='section-item display-flex align-items-center' onClick={(e) => this.toggleActiveSub(item)}>
                          <div className='title'>{this.renderTitle(item)}</div>
                          <DragHandle />
                        </li>
                      }
                    />
                  ))
                }
              </SortableContainer>
              <SortableContainer onSortEnd={this.onSortFooterEnd} useDragHandle>
                {
                  footerSections.map((item, index) => (
                    <SortableItem
                      key={`section-item-${item.id}` || randomString()}
                      index={index}
                      item={item}
                      content={
                        <li key={`section-${item.id}`} className='section-item display-flex align-items-center' onClick={(e) => this.toggleActiveSub(item)}>
                          <div className='title'>{this.renderTitle(item)}</div>
                          <DragHandle />
                        </li>
                      }
                    />
                  ))
                }
              </SortableContainer>
            </ul>
            <button className='btn p-2 m-3' onClick={this.addMoreSection}>Add section</button>
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
    onlineStore: state.onlineStore,
    sections: state.onlineStore.sections,
  };
};

const mapDispatchToProps = {
  addSectionItem: onlineStoreActions.addSectionItem,
  updateSectionItem: onlineStoreActions.updateSectionItem,
  updateSectionsList: onlineStoreActions.updateSectionsList,
}

export default connect(mapStateToProps, mapDispatchToProps)(StoreSections)