import React from 'react';
import { Typography, Button, Card, CardActionArea, CardActions, CardContent, CardMedia } from '@material-ui/core';
import styled from 'styled-components';
import Modal from '../components/Modal';
import ContractForm from '../components/ContractForm';
import Currency from './Currency';

const CardStyle = styled(Card)`
	max-width: 245px;
	margin: 15px;
`;

const Image = styled(CardMedia)`
	height: 140px;
`;

class Fin4Card extends React.Component {
	constructor(props) {
		super(props);
		this.state = {
			isModalOpen: false
		};
	}
	toggleModal = () => {
		this.setState({ isModalOpen: !this.state.isModalOpen });
	};

	render() {
		return (
			<div>
				<CardStyle>
					<CardActionArea>
						<Image image={this.props.imagePath} title={this.props.title} />
						<CardContent>
							<Typography gutterBottom variant="h5" component="h2">
								{this.props.title}
							</Typography>
							<Typography variant="body2" color="textSecondary" component="p">
								{this.props.description}
							</Typography>
						</CardContent>
					</CardActionArea>
					<CardActions>
						<Button size="small" color="secondary" onClick={this.toggleModal}>
							{this.props.actionButtonText}
						</Button>
						<a href={this.props.readMore} rel="noopener noreferrer" target="_blank">
							<Button size="small" color="primary">
								Learn More
							</Button>
						</a>
					</CardActions>
				</CardStyle>

				<Modal
					isOpen={this.state.isModalOpen}
					handleClose={this.toggleModal}
					title="Please Enter The Amount"
					width="500px">
					Token: <Currency symbol={this.props.tokenInfo.symbol} name={this.props.tokenInfo.name} />
					<ContractForm
						contractAddress={this.props.tokenInfo.address}
						contractName="Fin4Token"
						// instead of passing the proofTypeName, make an extra getName() call for that?
						method="transfer"
						toggleModal={this.toggleModal.bind(this)}
						staticArgs={{
							recipient: this.props.recipientAddress
						}}
					/>
				</Modal>
			</div>
		);
	}
}

export default Fin4Card;
