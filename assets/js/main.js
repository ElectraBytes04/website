import { Octokit } from "https://esm.sh/@octokit/rest";

const octokit = new Octokit();

async function fetchRepoInfo(card) {
	const owner = card.getAttribute('data-repo-owner');
	const repo = card.getAttribute('data-repo-name');
	const link = card.getAttribute('data-repo-link');

	try {
		const response = await octokit.request('GET /repos/{owner}/{repo}', 
			{ owner, repo });

		const name = response.data.full_name;
		const description = response.data.description;
		const stars = response.data.stargazers_count;
		const forks = response.data.forks;
		const issues = response.data.open_issues;

		printRepoInfo(card, link, name, description, stars, forks, issues);
	} catch (error) {
		console.log(error.message);
	}
}

function printRepoInfo(
	                     card, link,
	                     name, description, stars, forks, issues
                      ) {
	card.innerHTML = `<a href="${link}">
		${name}<br>
		${description}<br>
		Stars: ${stars}, Forks: ${forks}, Issues: ${issues}
		</a>`;
	console.log(link);
	console.log(name);
	console.log(description);
	console.log(stars);
	console.log(forks);
	console.log(issues);
}

document.querySelectorAll('.repo-card').forEach(card => {
	fetchRepoInfo(card);
});
