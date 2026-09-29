const axios = require('axios');
const cheerio = require('cheerio');
const core = require('@actions/core');

const version = process.argv[2]; // 从命令行参数获取 OpenWrt 版本
const filterTargetsStr = process.argv[3] || ''; // 按目标平台筛选（可选，使用逗号分隔）
const filterSubtargetsStr = process.argv[4] || ''; // 按子目标平台筛选（可选，使用逗号分隔）

// 将逗号分隔的字符串转换为数组
const filterTargets = filterTargetsStr ? filterTargetsStr.split(',').map(t => t.trim()).filter(t => t) : [];
const filterSubtargets = filterSubtargetsStr ? filterSubtargetsStr.split(',').map(s => s.trim()).filter(s => s) : [];

const excludedBuilds = [
  {
    target: 'microchipsw',
    subtarget: 'lan969x',
    reason: 'OpenWrt 25.12.x SDK 打包 kmod-crypto-xxhash 时失败：此专用目标平台已将 xxhash.ko 内置到内核中',
  },
];

if (!version) {
  core.setFailed('必须提供版本参数');
  process.exit(1);
}

const url = `https://downloads.openwrt.org/releases/${version}/targets/`;

async function fetchHTML(url) {
  try {
    const { data } = await axios.get(url);
    return cheerio.load(data);
  } catch (error) {
    console.error(`获取 ${url} 的 HTML 时出错：${error}`);
    throw error;
  }
}

async function getTargets() {
  const $ = await fetchHTML(url);
  const targets = [];
  $('table tr td.n a').each((index, element) => {
    const name = $(element).attr('href');
    if (name && name.endsWith('/')) {
      targets.push(name.slice(0, -1));
    }
  });
  return targets;
}

async function getSubtargets(target) {
  const $ = await fetchHTML(`${url}${target}/`);
  const subtargets = [];
  $('table tr td.n a').each((index, element) => {
    const name = $(element).attr('href');
    if (name && name.endsWith('/')) {
      subtargets.push(name.slice(0, -1));
    }
  });
  return subtargets;
}

async function getDetails(target, subtarget) {
  // 从 packages/index.json 获取软件包架构
  // apk 构建必须使用此方式，同时也兼容 ipk 构建
  const indexUrl = `${url}${target}/${subtarget}/packages/index.json`;
  let pkgarch = '';
  try {
    const { data } = await axios.get(indexUrl, { responseType: 'json' });
    pkgarch = data.architecture || '';
  } catch (e) {
    // 获取失败时保持软件包架构为空
  }

  // 从 kmods 目录名获取 vermagic，比解析内核文件名更可靠
  const kmodsUrl = `${url}${target}/${subtarget}/kmods/`;
  const $ = await fetchHTML(kmodsUrl);
  let vermagic = '';

  $('table tr td.n a').each((_, el) => {
    const name = $(el).attr('href');
    if (name && name.endsWith('/')) {
      vermagic = name.slice(0, -1);
      return false; // 结束遍历
    }
  });

  return { vermagic, pkgarch };
}

async function main() {
  try {
    const targets = await getTargets();
    const jobConfig = [];

    for (const target of targets) {
      // 如果指定了目标平台筛选器，则跳过不在其中的平台
      if (filterTargets.length > 0 && !filterTargets.includes(target)) {
        continue;
      }

      const subtargets = await getSubtargets(target);
      for (const subtarget of subtargets) {
        // 如果指定了子目标平台筛选器，则跳过不在其中的子平台
        if (filterSubtargets.length > 0 && !filterSubtargets.includes(subtarget)) {
          continue;
        }

        // 仅在以下情况下加入任务配置：
        // 1. 两个筛选数组均为空（由标签自动构建），构建全部平台；
        // 2. 两个筛选数组均非空（手动运行），目标平台和子目标平台都必须匹配。
        const isAutomatic = filterTargets.length === 0 && filterSubtargets.length === 0;
        const isManualMatch = filterTargets.length > 0 && filterSubtargets.length > 0 &&
                              filterTargets.includes(target) && filterSubtargets.includes(subtarget);
        
        if (!isAutomatic && !isManualMatch) {
          continue;
        }

        const excludedBuild = excludedBuilds.find(
          item => item.target === target && item.subtarget === subtarget
        );
        if (excludedBuild) {
          core.warning(`跳过 ${target}/${subtarget}：${excludedBuild.reason}`);
          continue;
        }

        const { vermagic, pkgarch } = await getDetails(target, subtarget);

        jobConfig.push({
          tag: version,
          target,
          subtarget,
          vermagic,
          pkgarch,
        });
      }
    }

    core.setOutput('job-config', JSON.stringify(jobConfig));
  } catch (error) {
    core.setFailed(error.message);
  }
}

main();
