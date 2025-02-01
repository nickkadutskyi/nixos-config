module.exports = {
	defaultBrowser: "Safari",
	options: {
		hideIcon: true,
	},
	rewrite: [
		{
			match: "https://app.clickup.com/*",
			url: ({ url }) => ({
				...url,
				host: "",
				protocol: "clickup"
			})
		},
	]
};
